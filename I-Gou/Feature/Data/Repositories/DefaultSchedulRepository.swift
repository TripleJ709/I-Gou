//
//  DefaultSchedulRepository.swift
//  I-Gou
//
//  Created by 장주진 on 10/14/25.
//

import Foundation

class DefaultScheduleRepository: ScheduleRepository {
    
    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchPlannerData() async throws -> PlannerData {
        return try await apiService.fetchPlannerData()
    }

    func addSchedule(title: String, date: Date, type: String, priority: String?) async throws {
        try await apiService.addSchedule(title: title, date: date, type: type, priority: priority)
    }
}
