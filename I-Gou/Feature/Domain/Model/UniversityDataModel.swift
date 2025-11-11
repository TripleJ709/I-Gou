//
//  UniversityDataModel.swift
//  I-Gou
//
//  Created by 장주진 on 11/11/25.
//

import Foundation
import SwiftUI

// MARK: - '내 대학' 탭 모델
// (이전에 UniversityItem으로 만들었던 것을 여기로 이동)
struct UniversityItem: Codable, Identifiable {
    let id: Int             // 1. [수정] 서버 DB의 Primary Key (Int)
    let universityName: String
    let department: String
    let major: String
    let myScore: Float
    let requiredScore: Float
    let deadline: String
    let status: String      // 2. [수정] "safe", "appropriate" 등 String
    let location: String
    let competitionRate: String
}

// MARK: - '입시 일정' 탭 모델
// GET /api/university/schedule 응답
struct AdmissionsScheduleData: Codable {
    let mainSchedule: [ScheduleItem]
    let dDayAlerts: [DDayItem]
}

struct ScheduleItem: Codable, Identifiable {
    let id: Int
    let dateLabel: String
    let title: String
    let tag: String
    let color: String // "red", "blue" 등
}

struct DDayItem: Codable, Identifiable {
    let id: Int
    let dDay: String // "D-7"
    let title: String
    let color: String
}

struct UniversitySearchResult: Codable, Hashable {
    let name: String
    let location: String
}

// 2. [추가] /api/university/departments 응답 모델
struct DepartmentSearchResult: Codable, Hashable {
    let schoolName: String
    let majorName: String
    let majorSeq: String // 고유 ID
}

struct NewsItem: Codable, Identifiable {
    let title: String
    let originallink: String // 원본 기사 URL
    let link: String         // 네이버 뉴스 URL (이걸 ID로 사용)
    let description: String
    let pubDate: String
    
    // 2. [추가] 'link'를 id로 사용
    var id: String { link }
    
    // 3. [추가] HTML 태그 제거 (b, &quot; 등)
    var cleanedTitle: String {
        title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
             .replacingOccurrences(of: "&quot;", with: "\"")
    }
    
    var cleanedDescription: String {
        description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                   .replacingOccurrences(of: "&quot;", with: "\"")
    }
}

struct SaveUniversityRequest: Codable {
    let universityName: String
    let location: String? // location은 UniversitySearchResult에만 있음
    let department: String
    let majorSeq: String
}

// [추가] 2. POST /api/university/my 응답 모델 (옵션)
struct SaveUniversityResponse: Codable {
    let message: String
    let insertedId: Int
}
