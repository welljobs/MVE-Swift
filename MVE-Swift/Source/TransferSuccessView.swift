//
//  TransferSuccessView.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/22.
//

import SwiftUI

struct TransferSuccessView: View {
    var body: some View {
        VStack {
            Text("传输成功")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding()
            
            Spacer()
            
            Button(action: {
                // 返回主页或进行其他操作
            }) {
                Text("完成")
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
#Preview {
    TransferSuccessView()
}


