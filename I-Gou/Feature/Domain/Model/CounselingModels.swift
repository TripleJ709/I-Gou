//
//  CounselingModels.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation

struct CounselingQuestion: Codable, Identifiable {
    let id: Int
    let category: String
    let question: String
    let answer: String?
    let counselorName: String? // JSON의 snake_case(counselor_name)를 매핑해야 함
    let status: String         // "waiting" or "answered"
    let date: String
    
    // JSON 키와 변수명 매핑
    enum CodingKeys: String, CodingKey {
        case id, category, question, answer, status, date
        case counselorName = "counselor_name"
    }
}

// MARK: - 질문 등록 요청 모델 (POST Body)
struct PostQuestionRequest: Codable {
    let question: String
    let category: String
}
