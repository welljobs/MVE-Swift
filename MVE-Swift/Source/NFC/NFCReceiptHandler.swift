//
//  NFCReceiptHandler.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/29.
//

import CoreNFC

// NFC 发送接收类
class NFCReceiptHandler: NSObject, NFCReceiptProcessable {
    
    private var nfcSession: NFCNDEFReaderSession
    
    init(nfcSession: NFCNDEFReaderSession) {
        self.nfcSession = nfcSession
    }
    
    func sendReceipt(_ receipt: NFCReceipt) throws {
        // 初始化NFC会话，并设置代理
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession.begin()
        
        // 生成NDEF消息
        let payload = NFCNDEFPayload(format: .nfcWellKnown, type: Data(), identifier: Data(), payload: Data("\(receipt.amount)".utf8), chunkSize: 0)
        let message = NFCNDEFMessage(records: [payload])
        
        // 在代理方法中处理写入
        nfcSession.alertMessage = "将设备靠近NFC标签以发送收据"
    }
    
    func receiveReceipt() throws -> NFCReceipt {
        var receivedReceipt: NFCReceipt?
        
        // 初始化NFC会话，并设置代理
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession.begin()
        
        throw NSError(domain: "com.example.NFC", code: 1001, userInfo: [NSLocalizedDescriptionKey: "接收收据功能正在运行"])
    }
}

// NFC 会话代理扩展
extension NFCReceiptHandler: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let amountString = String(data: record.payload, encoding: .utf8), let amount = Double(amountString) {
                    let receipt = NFCReceipt(id: UUID().uuidString, amount: amount, date: Date())
                    // 此处处理接收到的收据
                    print("收到收据: \(receipt)")
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("会话无效: \(error.localizedDescription)")
    }
    
    // 新增的代理方法，用于处理NFC标签连接
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "未检测到有效的NFC标签")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "连接标签失败: \(error.localizedDescription)")
                return
            }
            
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.invalidate(errorMessage: "无法查询NDEF状态: \(error.localizedDescription)")
                    return
                }
                
                switch status {
                case .notSupported:
                    session.invalidate(errorMessage: "NFC标签不支持NDEF")
                case .readWrite:
                    let payload = NFCNDEFPayload(format: .nfcWellKnown, type: Data(), identifier: Data(), payload: Data("10.0".utf8), chunkSize: 0)
                    let message = NFCNDEFMessage(records: [payload])
                    
                    tag.writeNDEF(message) { error in
                        if let error = error {
                            session.invalidate(errorMessage: "写入NDEF失败: \(error.localizedDescription)")
                        } else {
                            session.alertMessage = "收据已成功发送"
                            session.invalidate()
                        }
                    }
                case .readOnly:
                    session.invalidate(errorMessage: "NFC标签为只读")
                @unknown default:
                    session.invalidate(errorMessage: "未知NDEF状态")
                }
            }
        }
    }
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
}

class NFCService {
    private let receiptProcessor: NFCReceiptProcessable
    
    init(receiptProcessor: NFCReceiptProcessable) {
        self.receiptProcessor = receiptProcessor
    }
    
    func sendReceipt(_ receipt: NFCReceipt) {
        do {
            try receiptProcessor.sendReceipt(receipt)
        } catch {
            print("发送收据失败: \(error.localizedDescription)")
        }
    }
    
    func receiveReceipt() {
        do {
            let receipt = try receiptProcessor.receiveReceipt()
            print("收到收据: \(receipt)")
        } catch {
            print("接收收据失败: \(error.localizedDescription)")
        }
    }
}

