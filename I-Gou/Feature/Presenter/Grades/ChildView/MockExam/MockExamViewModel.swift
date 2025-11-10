//
//  MockExamViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 11/10/25.
//

//
//  MockExamViewModel.swift
//  I-Gou
//
//  Created by Gemini on 2025/11/10.
//

import Foundation
import Combine
import SwiftUI // Color

class MockExamViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI가 구독할 상태)
    
    // 막대 차트용 데이터
    @Published var barChartData: [MockExamScoreData] = []
    // 최근 결과 목록용 데이터
    @Published var recentResults: [MockExamRecentResult] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Use Cases (비즈니스 로직)
    
    private let fetchMockGradesUseCase: FetchMockGradesUseCase
    private let fetchMockRecentResultsUseCase: FetchMockRecentResultsUseCase

    // MARK: - Initializer (의존성 주입)
    
    init(
        fetchMockGradesUseCase: FetchMockGradesUseCase,
        fetchMockRecentResultsUseCase: FetchMockRecentResultsUseCase
    ) {
        self.fetchMockGradesUseCase = fetchMockGradesUseCase
        self.fetchMockRecentResultsUseCase = fetchMockRecentResultsUseCase
    }

    // MARK: - Public Methods
    
    @MainActor
    func fetchAllMockData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            // 함수 종료 시 로딩 상태 해제
            defer { isLoading = false }
            
            do {
                // 두 개의 API를 동시에 병렬로 호출
                async let barData = fetchMockGradesUseCase.execute()
                async let listData = fetchMockRecentResultsUseCase.execute()
                
                // 두 요청이 모두 완료되면 @Published 프로퍼티에 할당
                self.barChartData = (try await barData)
                    .filter { !$0.subject.isEmpty && !$0.month.isEmpty }
                
                // [수정] recentResults를 할당하기 전에 필터링
                self.recentResults = (try await listData)
                    .filter { !$0.examName.isEmpty }
                
                print("✅ 모의고사 막대 차트 데이터:", self.barChartData)
                print("✅ 모의고사 최근 결과 데이터:", self.recentResults)
                
            } catch {
                print("❌ 모의고사 데이터 로딩 실패:", error)
                self.errorMessage = "모의고사 데이터를 불러오는데 실패했습니다."
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // 막대 차트에서 사용할 색상 헬퍼
    func colorForSubject(_ subject: String) -> Color {
        switch subject {
        case "국어": return .orange
        case "수학": return .blue
        case "영어": return .green
//        case "탐구(1)" : return .yellow
//        case "탐구(2)" : return .purple
        default: return .gray
        }
    }
}
