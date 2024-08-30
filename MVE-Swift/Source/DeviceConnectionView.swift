//
//  DeviceConnectionView.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/22.
//

import SwiftUI
import CoreBluetooth

struct DeviceConnectionView: View {
    @StateObject private var bluetoothViewModel = BluetoothViewModel.shared
    @State private var inputData: String = "测试发送蓝牙数据" // 用于存储用户输入的数据
    @StateObject private var toastManager = ToastManager()
    @State private var buttonScale: CGFloat = 1.0 // 用于动画缩放
    
    var body: some View {
        VStack {
            // 扫描设备按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    buttonScale = 0.9 // 点击时缩小
                }
                //                toastManager.show(message: "开始扫描设备")
                bluetoothViewModel.startScan() // 重新初始化以重新扫描
                // 恢复原始尺寸
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        buttonScale = 1.0 // 恢复原始大小
                    }
                }
            }) {
                Text("扫描设备")
                    .font(.title3)
                    .padding()
                    .frame(width: 120, height: 120) // 设置按钮的固定宽度和高度
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle()) // 将按钮裁剪为圆形
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2) // 按钮的边框
                    )
                    .shadow(radius: 10) // 添加阴影效果
                    .scaleEffect(buttonScale) // 应用缩放效果
            }
            .padding()
            // 输入框用于输入数据
            TextField("输入数据", text: $inputData)
                .padding(10)
                .background(Color.white) // 背景色
                .cornerRadius(10) // 圆角
                .shadow(color: Color.white.opacity(0.3), radius: 5, x: 0, y: 2) // 阴影效果
                .padding(.horizontal)
                .textFieldStyle(PlainTextFieldStyle()) // 使用 PlainTextFieldStyle 以自定义背景
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2) // 边框颜色和宽度
                )
                .padding()
            
            
            // 发送数据
            Button(action: {
                // 将用户输入的数据转换为 Data 对象并发送
                if let data = inputData.data(using: .utf8) {
                    bluetoothViewModel.onSendSuccess = {
                        toastManager.show(message: "数据发送成功")
                    }
                    bluetoothViewModel.onSendFailure = {
                        toastManager.show(message: "数据发送失败")
                    }
                    let luoshenfu = """
                         黄初三年，余朝京师，还济洛川。古人有言：斯水之神，名曰宓妃。感宋玉对楚王神女之事，遂作斯赋。其辞曰：(对楚王 一作：对楚王说)
                    
                         　　余从京域，言归东藩，背伊阙，越轘辕，经通谷，陵景山。日既西倾，车殆马烦。尔乃税驾乎蘅皋，秣驷乎芝田，容与乎阳林，流眄乎洛川。于是精移神骇，忽焉思散。俯则未察，仰以殊观。睹一丽人，于岩之畔。乃援御者而告之曰：“尔有觌于彼者乎？彼何人斯，若此之艳也！”御者对曰：“臣闻河洛之神，名曰宓妃。然则君王之所见也，无乃是乎！其状若何？臣愿闻之。”
                    
                         　　余告之曰：其形也，翩若惊鸿，婉若游龙。荣曜秋菊，华茂春松。髣髴兮若轻云之蔽月，飘飖兮若流风之回雪。远而望之，皎若太阳升朝霞；迫而察之，灼若芙蕖出渌波。穠纤得衷，修短合度。肩若削成，腰如约素。延颈秀项，皓质呈露。芳泽无加，铅华弗御。云髻峨峨，修眉联娟。丹唇外朗，皓齿内鲜。明眸善睐，靥辅承权。瓌姿艳逸，仪静体闲。柔情绰态，媚于语言。奇服旷世，骨像应图。披罗衣之璀粲兮，珥瑶碧之华琚。戴金翠之首饰，缀明珠以耀躯。践远游之文履，曳雾绡之轻裾。微幽兰之芳蔼兮，步踟蹰于山隅。于是忽焉纵体，以遨以嬉。左倚采旄，右荫桂旗。攘皓腕于神浒兮，采湍濑之玄芝。(芙蕖 一作：芙蓉)
                    
                         　　余情悦其淑美兮，心振荡而不怡。无良媒以接欢兮，托微波而通辞。愿诚素之先达兮，解玉佩以要之。嗟佳人之信修兮，羌习礼而明诗。抗琼珶以和予兮，指潜渊而为期。执眷眷之款实兮，惧斯灵之我欺。感交甫之弃言兮，怅犹豫而狐疑。收和颜而静志兮，申礼防以自持。
                    
                         　　于是洛灵感焉，徙倚彷徨。神光离合，乍阴乍阳。竦轻躯以鹤立，若将飞而未翔。践椒涂之郁烈，步蘅薄而流芳。超长吟以永慕兮，声哀厉而弥长。尔乃众灵杂沓，命俦啸侣。或戏清流，或翔神渚，或采明珠，或拾翠羽。从南湘之二妃，携汉滨之游女。叹匏瓜之无匹兮，咏牵牛之独处。扬轻袿之猗靡兮，翳修袖以延伫。体迅飞凫，飘忽若神。凌波微步，罗袜生尘。动无常则，若危若安；进止难期，若往若还。转眄流精，光润玉颜。含辞未吐，气若幽兰。华容婀娜，令我忘餐。
                    
                         　　于是屏翳收风，川后静波。冯夷鸣鼓，女娲清歌。腾文鱼以警乘，鸣玉銮以偕逝。六龙俨其齐首，载云车之容裔。鲸鲵踊而夹毂，水禽翔而为卫。于是越北沚，过南冈，纡素领，回清扬。动朱唇以徐言，陈交接之大纲。恨人神之道殊兮，怨盛年之莫当。抗罗袂以掩涕兮，泪流襟之浪浪。悼良会之永绝兮，哀一逝而异乡。无微情以效爱兮，献江南之明珰。虽潜处于太阴，长寄心于君王。忽不悟其所舍，怅神宵而蔽光。
                    
                         　　于是背下陵高，足往神留。遗情想像，顾望怀愁。冀灵体之复形，御轻舟而上溯。浮长川而忘反，思绵绵而增慕。夜耿耿而不寐，沾繁霜而至曙。命仆夫而就驾，吾将归乎东路。揽騑辔以抗策，怅盘桓而不能去。
                    """
                    guard let textData = luoshenfu.data(using: .utf8) else { return }
                    guard let button = UIImage(named: "osc_button_bg"), let osc = button.pngData() else { return }
                    bluetoothViewModel.send(data: osc)
                } else {
                    print("无法将输入数据转换为 Data 对象")
                }
            }) {
                Text("发送数据")
                    .font(.title3)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity) // 设置按钮宽度自适应
            .padding(.horizontal, 15) // 设置左右边距为 15
            
            Spacer()
            
            // 扫描到的设备列表
            List(bluetoothViewModel.devices) { device in
                HStack {
                    Image(systemName: device.iconName) // 显示设备图标
                        .resizable()
                        .aspectRatio(contentMode: .fit) // 保持图标比例
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading) {
                        Text(device.name) // 显示设备名称
                            .font(.headline)
                        Text(device.isConnected ? "已连接" : "未连接") // 显示设备状态
                            .font(.subheadline)
                            .foregroundColor(device.isConnected ? .green : .red)
                    }
                    
                    Spacer()
                    
                    if device.isConnected {
                        Button(action: {
                            bluetoothViewModel.disconnect(from: device)
                        }) {
                            Text("断开")
                                .foregroundColor(.blue)
                        }
                    } else {
                        Button(action: {
                            bluetoothViewModel.connect(to: device)
                        }) {
                            Text("连接")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
        }
        .overlay(
            ToastView(message: toastManager.message, duration: toastManager.duration, isShowing: $toastManager.isShowing)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            // 当视图出现时开始扫描
            bluetoothViewModel.onReceivedSuccess = { received in
                print("Callback received with string: \(received)")
                toastManager.show(message: received)
            }
//            bluetoothViewModel.delegate = self
        }
        .onDisappear {
            // 当视图消失时停止扫描
            bluetoothViewModel.stopScan()
        }
    }
}
//extension DeviceConnectionView: BluetoothPeripheralDelegate {
//    func didDiscoverDevice(_ device: CBPeripheral) {
//        
//    }
//    
//    func didConnect(_ device: CBPeripheral) {
//        
//    }
//    
//    func didDisconnect(_ device: CBPeripheral) {
//        
//    }
//    
//    func didReceiveData(_ data: Data) {
//        // 处理接收到的数据
//        print("Received data: \(data)")
//    }
//    
//    func didSendData(_ data: Data) {
//        // 处理发送的数据
//        print("Sent data: \(data)")
//    }
//    
//    func didDiscoverService(_ service: CBService) {
//        // 处理服务发现
//        print("Discovered service: \(service.uuid)")
//    }
//}
#Preview {
    DeviceConnectionView()
}


