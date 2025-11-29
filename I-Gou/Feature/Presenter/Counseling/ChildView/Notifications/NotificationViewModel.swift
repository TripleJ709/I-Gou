//
//  NotificationViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation
import Combine

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func fetchNotifications() {
        Task {
            do {
                self.notifications = try await repository.fetchNotifications()
            } catch {
                print("알림 로드 실패: \(error)")
            }
        }
    }
}
