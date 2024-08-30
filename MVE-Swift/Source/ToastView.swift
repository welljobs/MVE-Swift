//
//  ToastView.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/23.
//

import SwiftUI

class ToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""
    var duration: Double = 2.0

    func show(message: String, duration: Double = 2.0) {
        self.message = message
        self.duration = duration
        self.isShowing = true
    }
}

struct ToastView: View {
    var message: String
    var duration: Double

    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            Spacer()
            if isShowing {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34) // 设置图片大小
                        .foregroundColor(.yellow)
                        .padding(.leading, 15) // 左侧内边距
                    Text(message)
                        .padding(10)
                        .foregroundColor(.white)
//                    Spacer() // 使图片和文本分开
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .shadow(radius: 10) // 添加阴影效果
                .frame(maxWidth: .infinity, alignment: .center) // 根据内容自适应宽度，并居中显示
                .padding(.horizontal, 16) // 设置水平边距
                .transition(.opacity)
                .animation(.easeInOut, value: isShowing)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            self.isShowing = false
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.clear) // 确保 ToastView 背景透明，以便居中显示
    }
}

#Preview {
    ToastView(message: "这是一个提示", duration: 3, isShowing: .constant(true))
}


