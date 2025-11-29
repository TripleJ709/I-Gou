//
//  DefaultCounselingRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation

class DefaultCounselingRepository: CounselingRepository {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchMyQuestions() async throws -> [CounselingQuestion] {
        return try await apiService.fetchMyQuestions()
    }
    
    func postQuestion(question: String, category: String) async throws {
        try await apiService.postQuestion(question: question, category: category)
    }
}
