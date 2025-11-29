//
//  CounselingRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation

protocol CounselingRepository {
    func fetchMyQuestions() async throws -> [CounselingQuestion]
    func postQuestion(question: String, category: String) async throws
}
