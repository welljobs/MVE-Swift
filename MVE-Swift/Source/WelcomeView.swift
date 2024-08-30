//
//  WelcomeView.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/22.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isActive = true
    var body: some View {
        ZStack {
            if isActive {
                VStack {
                    Spacer()
                    Text("欢迎使用")
                        .font(.largeTitle)
                        .padding()
                    
                    Spacer()
                    VStack {
                        
                        Text("正在进入主页面...")
                            .font(.title3)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 15) // 添加水平边距
                    .padding(.bottom, 15) // 添加底部边距
                }
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.isActive = false
                        }
                    }
                }
            } else {
                MainPageView().transition(.opacity)
            }
        }
        
        .animation(.easeInOut, value: isActive)
    }
}
#Preview {
    WelcomeView()
}


