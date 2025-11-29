//
//  CounselingUseCase.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation

class FetchMyQuestionsUseCase {
    private let repository: CounselingRepository
    
    init(repository: CounselingRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [CounselingQuestion] {
        return try await repository.fetchMyQuestions()
    }
}

class PostQuestionUseCase {
    private let repository: CounselingRepository
    
    init(repository: CounselingRepository) {
        self.repository = repository
    }
    
    func execute(question: String, category: String) async throws {
        try await repository.postQuestion(question: question, category: category)
    }
}
