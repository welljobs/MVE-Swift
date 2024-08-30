//
//  BluetoothViewModel.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/22.
//

import SwiftUI
import CoreBluetooth
import Compression

// 数据模型，用于表示发现的设备
struct DeviceModel: Identifiable {
    let id = UUID()
    let peripheral: CBPeripheral
    var isConnected: Bool
    var iconName: String
    
    // 设备名称，如果没有名称，则返回“未知设备”
    var name: String {
        peripheral.name ?? "未知设备"
    }
}
// 综合蓝牙操作的协议
protocol BluetoothPeripheralDelegate: AnyObject {
    // 设备发现
    func didDiscoverDevice(_ device: CBPeripheral)
    
    // 连接管理
    func didConnect(_ device: CBPeripheral)
    func didDisconnect(_ device: CBPeripheral)
    
    // 数据传输
    func didReceiveData(_ data: Data)
    func didSendData(_ data: Data)
    
    // 服务发现
    func didDiscoverService(_ service: CBService)
}
class BluetoothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var devices: [DeviceModel] = []  // 存储发现的设备
    private var centralManager: CBCentralManager!  // Core Bluetooth 中心管理器
    private var connectedPeripheral: CBPeripheral?  // 当前连接的外设
    private var writeCharacteristic: CBCharacteristic?  // 写入特征
    private var notifyCharacteristic: CBCharacteristic?  // 通知特征
    static let shared = BluetoothViewModel()
    var onSendSuccess: (() -> Void)?
    var onSendFailure: (() -> Void)?
    var onReceivedSuccess: ((String) -> Void)?
    
    weak var delegate: BluetoothPeripheralDelegate?
    var receivedBuffer = Data() // 缓冲区用于存储接收到的数据
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)  // 初始化中心管理器
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // 蓝牙已开启，开始扫描设备
            startScan()
        } else {
            print("蓝牙未打开或不可用")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 过滤掉名字为空的设备
        guard let deviceName = peripheral.name, !deviceName.isEmpty else {
            return
        }
        
        // 如果设备已经在列表中，更新设备的连接状态
        if let existingIndex = devices.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            devices[existingIndex].isConnected = false // 默认未连接
        } else {
            // 新发现的设备，添加到列表
            let device = DeviceModel(peripheral: peripheral, isConnected: false, iconName: "iphone.gen1")
            print("发现设备：\(device.name)")
            devices.append(device)
        }
        delegate?.didDiscoverDevice(peripheral) // 通知设备发现
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        
        // 更新设备的连接状态
        if let index = devices.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            devices[index].isConnected = true
            // 触发视图更新
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        
        // 设置 peripheral 的 delegate
        peripheral.delegate = self
        // 设置连接的外设
        connectedPeripheral = peripheral
        // 发现 peripheral 的服务
        peripheral.discoverServices(nil)
        delegate?.didConnect(peripheral) // 通知连接成功
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown")")
        
        if let error = error {
            print("Error during disconnection: \(error.localizedDescription)")
        }
        
        // 更新设备的连接状态
        if let index = devices.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            devices[index].isConnected = false
            // 触发视图更新
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            connect(to: devices[index])
        }
        
        delegate?.didDisconnect(peripheral) // 通知断开连接
        // 可以在这里进行重新连接的操作
        // 比如尝试重新连接
        // centralManager.connect(peripheral, options: nil)
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else { return }
        // 发现服务后，查找特征
        for service in services {
            delegate?.didDiscoverService(service) // 通知服务发现
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        
        // 发现特征后，找到写入特征和通知特征
        for characteristic in service.characteristics ?? [] {
            if characteristic.properties.contains(.write) {
                writeCharacteristic = characteristic
            }
            if characteristic.properties.contains(.notify) {
                notifyCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)  // 订阅特征的通知
            }
        }
    }
    /// 收到外围设备发过来的数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error updating value: \(error!.localizedDescription)")
            return
        }
        guard let startMarker = "<START>".data(using: .utf8), let endMarker = "<END>".data(using: .utf8) else {
            return
        }
        
        if characteristic == notifyCharacteristic {
            // 处理接收到的数据
            if let data = characteristic.value {
                receivedBuffer.append(data)
                while let startRange = receivedBuffer.range(of: startMarker) {
                    if let endRange = receivedBuffer.range(of: endMarker, options: [], in: startRange.upperBound..<receivedBuffer.endIndex) {
                        let message = receivedBuffer[startRange.upperBound..<endRange.lowerBound]
                        receivedBuffer.removeSubrange(receivedBuffer.startIndex..<endRange.upperBound)
                        
                        if let response = String(data: message, encoding: .utf8) {
                            print("Full message received: \(response)")
                            onReceivedSuccess?(response)
                            delegate?.didReceiveData(data) // 通知接收到数据
                        }

                    } else {
                        break
                    }
                }
            }
        }
    }
    /// 数据发送成功或者失败的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            onSendFailure?()
            print("Error writing value for characteristic: \(error.localizedDescription)")
        } else {
            onSendSuccess?()
            print("Successfully wrote value for characteristic: \(characteristic.uuid)")
        }
    }
    // MARK: - Public Methods
    
    // 连接到设备
    func connect(to device: DeviceModel) {
        guard let peripheral = devices.first(where: { $0.id == device.id })?.peripheral else {
            print("Device not found.")
            return
        }
        print("start connected \(String(describing: peripheral.name))")
        centralManager.connect(peripheral, options: nil)
    }
    
    // 断开连接
    func disconnect(from device: DeviceModel) {
        guard let peripheral = devices.first(where: { $0.id == device.id })?.peripheral else {
            print("Device not found.")
            return
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    // 开始扫描设备
    func startScan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    // 停止扫描设备
    func stopScan() {
        centralManager.stopScan()
    }
    
    // 发送数据到设备
    func send(data: Data) {
        guard let peripheral = connectedPeripheral, let characteristic = writeCharacteristic else {
            print("Peripheral or characteristic not found.")
            return
        }
        let maxLength = 512 // 默认 BLE 最大有效负载长度
        var offset = 0
        guard let compressedData = compressData(data) else {
            return
        }
        
        guard let startMarker = "<START>".data(using: .utf8), let endMarker = "<END>".data(using: .utf8) else {
            return
        }
        
        // 将整个消息构造为一个带有协议标记的字符串
        let combinedData = startMarker + compressedData + endMarker
        var index = 0
        while offset < combinedData.count {
            let chunkSize = min(maxLength, combinedData.count - offset)
            let chunk = combinedData.subdata(in: offset..<offset + chunkSize)
            print("send data:\(chunk)")

            peripheral.writeValue(chunk, for: characteristic, type: .withResponse)
            offset += chunkSize
            index += 1;
        }
        print("数据发送完毕 offset:\(offset), index:\(index)")
        // 更新回调
        onSendSuccess?()
        delegate?.didSendData(combinedData) // 通知数据发送完成
    }
}
extension BluetoothViewModel {
    func compressData(_ data: Data) -> Data? {
        let sourceBuffer = [UInt8](data)
        var destinationBuffer = [UInt8](repeating: 0, count: data.count * 2)
        
        let compressedSize = compression_encode_buffer(
            &destinationBuffer,
            destinationBuffer.count,
            sourceBuffer,
            sourceBuffer.count,
            nil,
            COMPRESSION_ZLIB
        )
        
        guard compressedSize > 0 else {
            return nil
        }
        
        return Data(bytes: destinationBuffer, count: compressedSize)
    }
    // 解压缩大数据的函数
    func decompressData(_ data: Data) -> Data? {
        let sourceBuffer = [UInt8](data)
        var destinationBuffer = [UInt8](repeating: 0, count: data.count * 4)

        let decompressedSize = compression_decode_buffer(
            &destinationBuffer,
            destinationBuffer.count,
            sourceBuffer,
            sourceBuffer.count,
            nil,
            COMPRESSION_ZLIB
        )

        guard decompressedSize > 0 else {
            return nil
        }

        return Data(bytes: destinationBuffer, count: decompressedSize)
    }
    // 压缩数据分块处理
    func compressDataInChunks(_ data: Data, _ chunkSize: Int) -> Data? {
        var compressedData = Data()
        
        var startIndex = data.startIndex
        while startIndex < data.endIndex {
            let endIndex = data.index(startIndex, offsetBy: chunkSize, limitedBy: data.endIndex) ?? data.endIndex
            let chunk = data[startIndex..<endIndex]
            
            if let compressedChunk = compressData(chunk) {
                compressedData.append(compressedChunk)
            } else {
                return nil
            }
            
            startIndex = endIndex
        }
        
        return compressedData
    }

    // 解压缩数据分块处理
    func decompressDataInChunks(_ data: Data, _ chunkSize: Int) -> Data? {
        var decompressedData = Data()
        
        var startIndex = data.startIndex
        while startIndex < data.endIndex {
            let endIndex = data.index(startIndex, offsetBy: chunkSize, limitedBy: data.endIndex) ?? data.endIndex
            let chunk = data[startIndex..<endIndex]
            
            if let decompressedChunk = decompressData(chunk) {
                decompressedData.append(decompressedChunk)
            } else {
                return nil
            }
            
            startIndex = endIndex
        }
        
        return decompressedData
    }

}
