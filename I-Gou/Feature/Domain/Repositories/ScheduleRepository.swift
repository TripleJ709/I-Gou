//
//  ScheduleRepository.swift
//  I-Gou
//
//  Created by 장주진 on 10/14/25.
//

import Foundation

protocol ScheduleRepository {
    func fetchPlannerData() async throws -> PlannerData
    func addSchedule(title: String, date: Date, type: String, priority: String?) async throws
}
