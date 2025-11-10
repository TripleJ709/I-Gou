//
//  GradeUseCase.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import Foundation

// --- 내신 성적 조회 UseCase ---
class FetchInternalGradesUseCase {
    private let repository: GradeRepository

    init(repository: GradeRepository) {
        self.repository = repository
    }

    func execute() async throws -> [SubjectScoreData] {
        try await repository.fetchInternalGradesForChart()
    }
}

// --- [추가] 성적 추가 UseCase ---
class AddGradeUseCase {
    private let repository: GradeRepository

    init(repository: GradeRepository) {
        self.repository = repository
    }

    // 새로운 성적 기록(국/영/수 포함)을 DB에 추가하는 기능
    // examType은 "내신" 또는 "모의고사"
    // examDate는 성적 추가 화면에서 받아야 함 (현재 InternalGradeRecord에는 없음)
    func execute(examType: String, examName: String, subject: String, score: Int, gradeLevel: String?, examDate: Date) async throws {
        try await repository.addGrade(examType: examType, examName: examName, subject: subject, score: score, gradeLevel: gradeLevel, examDate: examDate)
    }
}

class FetchGradeDistributionUseCase {
    private let repository: GradeRepository
    
    init(repository: GradeRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [GradeDistributionResponse] {
        try await repository.fetchGradeDistribution()
    }
}

class FetchMockGradesUseCase {
    private let repository: GradeRepository
    init(repository: GradeRepository) { self.repository = repository }
    func execute() async throws -> [MockExamScoreData] {
        try await repository.fetchMockGradesForChart()
    }
}

// --- [신규] 최근 모의고사 결과 조회 (목록용) ---
class FetchMockRecentResultsUseCase {
    private let repository: GradeRepository
    init(repository: GradeRepository) { self.repository = repository }
    func execute() async throws -> [MockExamRecentResult] {
        try await repository.fetchMockRecentResults()
    }
}
