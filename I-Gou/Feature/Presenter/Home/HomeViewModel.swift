//
//  HomeViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var homeData: HomeData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchHomeDataUseCase: FetchHomeDataUseCase
    
    // 생성자 주입 (DI)
    init(fetchHomeDataUseCase: FetchHomeDataUseCase) {
        self.fetchHomeDataUseCase = fetchHomeDataUseCase
    }
    
    func fetchHomeData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                let data = try await fetchHomeDataUseCase.execute()
                self.homeData = data
            } catch {
                print("홈 데이터 로드 실패: \(error)")
                self.errorMessage = "홈 데이터를 불러오는데 실패했습니다."
            }
        }
    }
}
