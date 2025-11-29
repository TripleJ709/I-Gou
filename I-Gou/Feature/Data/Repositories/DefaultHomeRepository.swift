//
//  DefaultHomeRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/30/25.
//

import Foundation

class DefaultHomeRepository: HomeRepository {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchHomeData() async throws -> HomeData {
        // APIService에 이미 만들어두신 fetchHomeData()를 활용합니다.
        return try await apiService.fetchHomeData()
    }
}
