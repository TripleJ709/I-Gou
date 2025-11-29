//
//  NotificationRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation

protocol NotificationRepository {
    func fetchNotifications() async throws -> [NotificationItem]
}


