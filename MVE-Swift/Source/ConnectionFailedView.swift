//
//  ConnectionFailedView.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/22.
//

import SwiftUI

struct ConnectionFailedView: View {
    var body: some View {
        VStack {
            Text("连接失败")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            Image(systemName: "xmark.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
                .padding()
            
            Spacer()
            
            Button(action: {
                // 重试连接
            }) {
                Text("重试")
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
#Preview {
    ConnectionFailedView()
}


