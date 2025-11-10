//
//  DefaultGradeRepository.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import Foundation

class DefaultGradeRepository: GradeRepository {
    
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    // 내신 성적 조회 함수 구현
    func fetchInternalGradesForChart() async throws -> [SubjectScoreData] {
        return try await apiService.fetchInternalGrades()
    }
    
    // 모의고사 성적 조회 함수 구현
    func fetchMockGradesForChart() async throws -> [MockExamScoreData] {
        return try await apiService.fetchMockGrades()
    }
    
    // 성적 추가 함수 구현
    func addGrade(examType: String, examName: String, subject: String, score: Int, gradeLevel: String?, examDate: Date) async throws {
        try await apiService.addGrade(examType: examType, examName: examName, subject: subject, score: score, gradeLevel: gradeLevel, examDate: examDate)
    }
    
    // 등급 분포 조회 함수 구현
    func fetchGradeDistribution() async throws -> [GradeDistributionResponse] {
        return try await apiService.fetchGradeDistribution()
    }
    
    func fetchMockRecentResults() async throws -> [MockExamRecentResult] {
        // 실제 작업은 APIService에 위임합니다.
        return try await apiService.fetchMockRecentResults()
    }
}
