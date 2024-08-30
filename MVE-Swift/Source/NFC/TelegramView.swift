//
//  TelegramView.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/30.
//

import SwiftUI

struct TelegramView: View {
    let initialRadius: CGFloat
    let radiusIncrement: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let position = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let maxRadius = min(geometry.size.width, geometry.size.height) / 2
            
            let circles = stride(from: initialRadius, to: maxRadius, by: radiusIncrement).map { radius in
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(position)
            }
            
            ZStack {
                ForEach(circles.indices, id: \.self) { index in
                    circles[index]
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }
    }
}
#Preview {
    TelegramView(initialRadius: 50, radiusIncrement: 50)
}
