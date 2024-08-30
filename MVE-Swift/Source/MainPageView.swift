//
//  MainPageView.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/22.
//

import SwiftUI

struct MainPageView: View {
    var body: some View {
        TabView {
            DeviceConnectionView()
                .tabItem {
                    Image(systemName: "wifi")
                    Text("设备连接")
                }

            VideoTransferView()
                .tabItem {
                    Image(systemName: "video")
                    Text("画面传输")
                }
        }
    }
}

#Preview {
    MainPageView()
}


