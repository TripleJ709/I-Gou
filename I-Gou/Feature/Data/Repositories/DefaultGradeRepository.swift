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
    
    func fetchInternalGradesForChart() async throws -> [SubjectScoreData] {
        return try await apiService.fetchInternalGrades()
    }
    
    func fetchMockGradesForChart() async throws -> [MockExamScoreData] {
        return try await apiService.fetchMockGrades()
    }
    
    func addGrade(examType: String, examName: String, subject: String, score: Int, gradeLevel: String?, examDate: Date) async throws {
        try await apiService.addGrade(examType: examType, examName: examName, subject: subject, score: score, gradeLevel: gradeLevel, examDate: examDate)
    }
}
