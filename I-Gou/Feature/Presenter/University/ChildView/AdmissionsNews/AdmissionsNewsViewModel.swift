//
//  AdmissionsNewsViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 11/12/25.
//

import Foundation
import Combine

@MainActor
class AdmissionsNewsViewModel: ObservableObject {
    
    @Published var newsItems: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchNewsUseCase: FetchNewsUseCase
    
    init(fetchNewsUseCase: FetchNewsUseCase) {
        self.fetchNewsUseCase = fetchNewsUseCase
    }
    
    func fetchNews() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                self.newsItems = try await fetchNewsUseCase.execute()
            } catch {
                self.errorMessage = "뉴스 로딩에 실패했습니다."
            }
        }
    }
}
