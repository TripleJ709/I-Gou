//
//  GradeDataModel.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import SwiftUI

// MARK: - ExamScore
struct ExamScore: Codable, Identifiable {
    let id = UUID() // Identifiable을 위해 추가
    let month: String // JSON의 'month' 키 (예: "1학기 중간")
    let score: Int    // JSON의 'score' 키
    let date: String
    
}

// MARK: - SubjectScoreData
// 서버 /api/grades/internal 응답 배열의 각 객체에 해당하는 구조체
struct SubjectScoreData: Codable, Identifiable {
    let id = UUID()
    let subject: String
    let scores: [ExamScore] // ✅ 이제 ExamScore 타입을 찾을 수 있습니다.
    
    enum CodingKeys: String, CodingKey {
        case subject, scores
    }
}


// MARK: - MockExamScoreData (이전과 동일)
struct MockExamScoreData: Codable, Identifiable {
    let id = UUID()
    let month: String
    let subject: String
    let score: Int
    let color: String?

    enum CodingKeys: String, CodingKey {
        case month, subject, score, color
    }
}

// MARK: - AddGradeRequest (이전과 동일)
struct AddGradeRequest: Codable {
    let examType: String
    let examName: String
    let subjectName: String
    let score: Int
    let gradeLevel: String?
    let examDate: String
}

struct ExamChartData: Identifiable {
    var id = UUID()
    var examName: String // month -> examName
    var score: Int
    var examDate: Date // 실제 Date 객체
}
