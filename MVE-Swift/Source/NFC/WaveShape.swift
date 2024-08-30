//
//  WaveShape.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/29.
//

import SwiftUI

struct WaveShape: Shape {
    var phase: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let amplitude: CGFloat = 10
        let frequency: CGFloat = 2

        path.move(to: CGPoint(x: 0, y: height / 2))

        for x in stride(from: 0, through: width, by: 1) {
            // Intermediate calculations
            let normalizedX = CGFloat(x) / CGFloat(width)
            let radians = frequency * normalizedX * .pi * 2
            
            let phaseOffset = radians + CGFloat(phase)
            let sineValue = sinf(Float(phaseOffset))
            let verticalOffset = Float(height / 2)

            let y = Float(amplitude) * sineValue + verticalOffset
            path.addLine(to: CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

struct WaveContentView: View {
    @State private var phase: Double = 0

    var body: some View {
        VStack {
            WaveShape(phase: phase)
                .fill(Color.blue)
                .frame(height: 100)
                .offset(y: 50) // Optional: adjust vertical position
            
            // You can add other UI elements here

        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
            ) {
                phase = .pi * 2
            }
        }
    }
}
#Preview {
    WaveContentView()
}
