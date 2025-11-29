//
//  HomeUseCase.swift
//  I-Gou
//
//  Created by 장주진 on 11/30/25.
//

import Foundation

class FetchHomeDataUseCase {
    private let repository: HomeRepository
    
    init(repository: HomeRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> HomeData {
        return try await repository.fetchHomeData()
    }
}
