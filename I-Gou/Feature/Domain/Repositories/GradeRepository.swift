//
//  GradeRepository.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import Foundation

protocol GradeRepository {
    func fetchInternalGradesForChart() async throws -> [SubjectScoreData]
    func fetchMockGradesForChart() async throws -> [MockExamScoreData]
    func addGrade(examType: String, examName: String, subject: String, score: Int, gradeLevel: String?, examDate: Date) async throws
    func fetchGradeDistribution() async throws -> [GradeDistributionResponse]
    func fetchMockRecentResults() async throws -> [MockExamRecentResult]
}
