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
    let universityNews: [UniversityNews]
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

// MARK: - UniversityNews
struct UniversityNews: Codable, Identifiable {
    let id = UUID()
    let universityName: String
    let title: String
    let isNew: Bool
    let content: String // 상세 페이지 내용

    // JSON의 snake_case 키를 Swift의 camelCase 프로퍼티에 매핑
    enum CodingKeys: String, CodingKey {
        case universityName, title, isNew, content
    }
}
