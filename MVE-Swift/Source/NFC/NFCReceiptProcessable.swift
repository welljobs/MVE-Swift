//
//  NFCReceiptProcessable.swift
//  MVE-Swift
//
//  Created by Jobs Azeroth on 2024/8/29.
//

import Foundation

// 收据模型
struct NFCReceipt {
    let id: String
    let amount: Double
    let date: Date
    // 其他收据相关信息
}
// NFC 收据处理协议
protocol NFCReceiptProcessable {
    func sendReceipt(_ receipt: NFCReceipt) throws
    func receiveReceipt() throws -> NFCReceipt
}
