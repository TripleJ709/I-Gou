//
//  HomeData.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import Foundation

// MARK: - HomeData
struct HomeData: Codable {
    let user: User
    let todaySchedules: [Schedule]
    let recentGrades: [Grade]
    let notifications: [Notification]
    let universityNews: [UniversityNews]
}

// MARK: - User
struct User: Codable {
    let name: String
}

// MARK: - Schedule
struct Schedule: Codable, Identifiable {
    let id = UUID() // Identifiable을 위해 추가
    let startTime: String
    let title: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case startTime, title, type
    }
}

// MARK: - Grade
struct Grade: Codable, Identifiable {
    let id = UUID()
    let subjectName: String
    let score: Int
    let gradeLevel: String?

    enum CodingKeys: String, CodingKey {
        case subjectName, score, gradeLevel
    }
}

// MARK: - Notification
struct Notification: Codable, Identifiable {
    let id = UUID()
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
    let content: String

    enum CodingKeys: String, CodingKey {
        case universityName, title, isNew, content
    }
}
