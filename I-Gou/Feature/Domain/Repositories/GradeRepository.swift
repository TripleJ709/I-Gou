//
//  GradeRepository.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import Foundation

protocol GradeRepository {
    // 내신 성적 조회 (라인 차트용 데이터)
    func fetchInternalGradesForChart() async throws -> [SubjectScoreData]
    
    // 모의고사 성적 조회 (막대 그래프용 데이터)
    func fetchMockGradesForChart() async throws -> [MockExamScoreData]
    
    // 새로운 성적 추가 (내신/모의고사 공통)
    func addGrade(examType: String, examName: String, subject: String, score: Int, gradeLevel: String?, examDate: Date) async throws
    
    func fetchGradeDistribution() async throws -> [GradeDistributionResponse]
    
    func fetchMockRecentResults() async throws -> [MockExamRecentResult]
}
