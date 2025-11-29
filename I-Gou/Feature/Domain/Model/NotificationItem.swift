//
//  NotificationItem.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation

struct NotificationItem: Codable, Identifiable {
    let id: Int
    let type: String
    let title: String
    let message: String
    let time: String
}
