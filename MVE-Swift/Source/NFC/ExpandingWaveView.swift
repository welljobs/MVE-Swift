//
//  ExpandingWaveView.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/29.
//

import SwiftUI
import Combine

// 单一职责：此类只负责管理圆圈的属性和动画逻辑
class CircleViewModel: ObservableObject, Identifiable {
    let id = UUID()
    let radius: CGFloat
    let limitRadius: CGFloat
    let duration: Double
    let borderWidth: CGFloat
    let position: CGPoint // 新增位置属性
    @Published var scale: CGFloat = 1.0
    @Published var opacity: Double = 1.0
    @Published var currentBorderWidth: CGFloat = 3.0
    
    private var timer: AnyCancellable?
    private var isActive: Bool = true
    
    init(radius: CGFloat, limitRadius: CGFloat, duration: Double, borderWidth: CGFloat, position: CGPoint) {
        self.radius = radius
        self.limitRadius = limitRadius
        self.duration = duration
        self.borderWidth = borderWidth
        self.position = position;
        startAnimation()
    }
    
    // 单一职责：启动动画并更新属性
    private func startAnimation() {
        guard isActive else { return }
        withAnimation(.easeOut(duration: duration)) {
            self.scale = limitRadius / radius
            self.opacity = 0.0
            self.currentBorderWidth = 0.0 // 边框宽度逐渐变宽
        }
        
        // 定时器用于重复动画
        timer = Timer.publish(every: duration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.scale = 1.0
                self?.opacity = 1.0
                self?.currentBorderWidth = self?.borderWidth ?? 3.0
                print("圆圈的尺寸:\(self?.currentBorderWidth ?? 0)")
                self?.startAnimation()
            }
    }
    func restartAnimation() {
        isActive = true
        startAnimation() // 重新启动动画
    }
    func stopAnimation() {
        isActive = false
        // 立即停止动画并恢复状态
        withAnimation {
            scale = 1.0
            opacity = 1.0
            currentBorderWidth = 0.0
        }
        timer?.cancel()
    }
    deinit {
        timer?.cancel()
    }
}

// 单一职责：此结构体只负责显示圆圈视图
struct CircleView: View {
    @ObservedObject var viewModel: CircleViewModel
    
    var body: some View {
        Circle()
            .stroke(Color.blue.opacity(0.5), lineWidth: viewModel.currentBorderWidth)
            .frame(width: viewModel.radius, height: viewModel.radius)
            .scaleEffect(viewModel.scale)
            .opacity(viewModel.opacity)
        //            .position(viewModel.position) // 使用 viewModel 的位置属性
    }
}

// 单一职责：此类只负责管理多个圆圈的生成和生命周期
class ExpandingWaveViewModel: ObservableObject {
    @Published var circles: [CircleViewModel] = []
    
    private let maxCircles = 8
    private var timer: AnyCancellable?
    private var lastSize: CGFloat = 50
    private var isActive = true
    init() {
        addNewCircle()
//        startGeneratingCircles()
    }
    
    // 单一职责：每隔一定时间生成一个新的圆圈
    func startGeneratingCircles() {
        guard isActive else { return }
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.addNewCircle()
            }
    }
    
    private func addNewCircle() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        // 每次生成的圆圈比上一个稍大
        let radius = lastSize + 50
        
        let limitRadius: CGFloat = min(screenWidth, screenHeight)
        // 边框宽度从3.0到4.0之间变化
        let borderWidth: CGFloat = 3.0 + (lastSize / radius)
        
        let position = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        let circleViewModel = CircleViewModel(radius: radius, limitRadius: limitRadius, duration: 2.0, borderWidth: borderWidth, position: position)
        circles.append(circleViewModel)
        
        if circles.count > maxCircles {
            circles.removeFirst()
        }
        
        // 更新 lastSize，以便下一个圆圈更大
        lastSize = (lastSize > screenWidth / 2) ? 50 : lastSize + 50 // 重置尺寸时从50开始
        print("圆圈的尺寸:\(lastSize)")
    }
    func restartAnimations() {
        isActive = true
        startGeneratingCircles()
    }
    func stopAllAnimations() {
        isActive = false
        // 停止所有圆圈的动画
        for circle in circles {
            circle.stopAnimation()
        }
        circles.removeAll()
        timer?.cancel()
    }
    deinit {
        timer?.cancel()
    }
}

// 单一职责：此结构体只负责显示所有圆圈的组合视图
struct ExpandingWaveView: View {
    @ObservedObject var viewModel = ExpandingWaveViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            let position = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ForEach(viewModel.circles) { circleViewModel in
                    CircleView(viewModel: circleViewModel)
                        .position(position)
                }
            }
        }
        .onAppear {
            // 启动动画
            viewModel.restartAnimations()
        }
        .onDisappear {
            // 停止所有动画
            viewModel.stopAllAnimations()
        }
    }
}

#Preview {
    ExpandingWaveView()
}
