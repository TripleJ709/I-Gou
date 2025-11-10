//
//  GradeDataModel.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import SwiftUI // Color 사용을 위해 필요

// MARK: - 1. UI용 차트 데이터 모델 (ViewModel이 이 형태로 변환)

/// 라인 차트가 사용할 데이터 모델
struct ExamChartData: Identifiable {
    var id = UUID()
    var examName: String // 예: "1학기 중간"
    var score: Int
    var examDate: Date   // 실제 Date 객체 (X축 정렬 기준)
}

/// 라인 차트의 과목별 시리즈 모델
struct SubjectPerformance: Identifiable {
    var id = UUID()
    var subject: String
    var scores: [ExamChartData]
    var color: Color

    func colorForSubject() -> Color {
        switch subject {
        case "국어": return .orange
        case "수학": return .blue
        case "영어": return .green
        default: return .gray
        }
    }
}

/// 파이 차트가 사용할 데이터 모델
struct GradeDistribution: Identifiable {
    var id = UUID()
    var grade: String
    var count: Int
    var color: Color
}


// MARK: - 2. API 응답(Response) 모델 (서버 JSON과 일치)

/// `/api/grades/internal` 응답용
struct SubjectScoreData: Codable, Identifiable {
    let id = UUID()
    let subject: String
    let scores: [ExamScore]
    
    enum CodingKeys: String, CodingKey {
        case subject, scores
    }
}

/// SubjectScoreData 내부의 `scores` 배열 항목용
struct ExamScore: Codable, Identifiable {
    let id = UUID()
    let month: String // exam_name
    let score: Int
    let date: String  // "YYYY-MM-DD..." 형식의 문자열
}

/// `/api/grades/mock` 응답용 (막대 차트)
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

/// `/api/grades/distribution` 응답용 (파이 차트)
struct GradeDistributionResponse: Codable {
    let grade_level: String // DB 컬럼 이름과 일치
    let count: Int
}

/// `/api/grades/mock/recent` 응답용 (목록)
struct MockExamRecentResult: Codable, Identifiable {
    var id: String { examName }
    let examName: String
    let examDate: String
    let scores: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case examName, examDate, scores
    }
}

// MARK: - 3. API 요청(Request) 모델

/// `POST /api/grades` 요청 본문용
struct AddGradeRequest: Codable {
    let examType: String
    let examName: String
    let subjectName: String
    let score: Int
    let gradeLevel: String?
    let examDate: String
}

// MARK: - 4. UI 입력 데이터 모델

/// '성적 추가' 화면에서 여러 과목을 임시 저장하는 모델
struct GradeInputData {
    var subject: String?
    var score: String?
    var gradeLevel: String?
}

/// '성적 추가' 화면에서 국/영/수 점수를 받는 모델 (이제 사용하지 않을 수 있음)
struct InternalGradeRecord {
    let examName: String
    let koreanScore: Int
    let mathScore: Int
    let englishScore: Int
}
