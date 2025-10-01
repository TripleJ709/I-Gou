//
//  PlannerData.swift
//  I-Gou
//
//  Created by 장주진 on 10/1/25.
//

import Foundation

struct PlannerData: Codable {
    let todaySchedules: [DailySchedule]
    let deadlines: [Deadline]
}

struct DailySchedule: Codable, Identifiable {
    let id: Int
    let time, title, subtitle, tag, color: String
}

struct Deadline: Codable, Identifiable {
    let id: Int
    let title, date, priority, color: String
}
