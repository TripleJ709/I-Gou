//
//  HomeData.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import Foundation

// MARK: - HomeData
// /api/home 에서 받는 최상위 JSON 객체에 해당하는 메인 구조체입니다.
struct HomeData: Codable {
    let user: User
    let todaySchedules: [Schedule]
    let recentGrades: [Grade]
    let notifications: [Notification]
}

// MARK: - User
// JSON의 'user' 객체에 해당합니다.
struct User: Codable {
    let name: String
}

// MARK: - Schedule
// JSON의 'todaySchedules' 배열에 들어갈 항목입니다.
struct Schedule: Codable, Identifiable {
    let id = UUID() // Identifiable을 위해 추가
    let startTime: String
    let title: String
    let type: String
    
    // JSON 키와 Swift 프로퍼티 이름이 다를 경우를 대비 (지금은 동일)
    enum CodingKeys: String, CodingKey {
        case startTime, title, type
    }
}

// MARK: - Grade
// JSON의 'recentGrades' 배열에 들어갈 항목입니다.
struct Grade: Codable, Identifiable {
    let id = UUID() // Identifiable을 위해 추가
    let subjectName: String
    let score: Int
    let gradeLevel: String

    enum CodingKeys: String, CodingKey {
        case subjectName, score, gradeLevel
    }
}

// MARK: - Notification
// JSON의 'notifications' 배열에 들어갈 항목입니다.
struct Notification: Codable, Identifiable {
    let id = UUID() // Identifiable을 위해 추가
    let content: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case content, createdAt
    }
}
