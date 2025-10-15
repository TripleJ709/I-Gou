//
//  PlannerUseCase.swift
//  I-Gou
//
//  Created by 장주진 on 10/14/25.
//

import Foundation

class FetchPlannerDataUseCase {
    private let repository: ScheduleRepository

    init(repository: ScheduleRepository) {
        self.repository = repository
    }

    func execute() async throws -> PlannerData {
        try await repository.fetchPlannerData()
    }
}

class AddScheduleUseCase {
    private let repository: ScheduleRepository

    init(repository: ScheduleRepository) {
        self.repository = repository
    }

    func execute(dailySchedule title: String, time: Date) async throws {
        try await repository.addSchedule(title: title, date: time, type: "학습", priority: nil)
    }
    
    func execute(deadline title: String, date: Date) async throws {
        try await repository.addSchedule(title: title, date: date, type: "마감일", priority: "보통")
    }
}
