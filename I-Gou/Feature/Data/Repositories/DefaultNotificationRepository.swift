//
//  DefaultNotificationRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation

class DefaultNotificationRepository: NotificationRepository {
    private let apiService: APIService
    init(apiService: APIService) { self.apiService = apiService }
    
    func fetchNotifications() async throws -> [NotificationItem] {
        return try await apiService.fetchNotifications()
    }
}
