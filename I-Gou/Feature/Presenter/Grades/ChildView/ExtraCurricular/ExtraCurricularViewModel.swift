//
//  ExtraCurricularViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 11/10/25.
//

import Foundation
import Combine

class ExtraCurricularViewModel: ObservableObject {
    @Published var extraData: ExtraCurricularData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchUseCase: FetchExtraCurricularDataUseCase
    private let addActivityUseCase: AddActivityUseCase // [추가]
    private let addReadingUseCase: AddReadingUseCase   // [추가]
    
    init(
        fetchUseCase: FetchExtraCurricularDataUseCase,
        addActivityUseCase: AddActivityUseCase, // [추가]
        addReadingUseCase: AddReadingUseCase    // [추가]
    ) {
        self.fetchUseCase = fetchUseCase
        self.addActivityUseCase = addActivityUseCase
        self.addReadingUseCase = addReadingUseCase
    }
    
    @MainActor
    func fetchData() {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                self.extraData = try await fetchUseCase.execute()
                print("✅ 비교과 데이터:", self.extraData ?? "없음")
            } catch {
                self.errorMessage = "비교과 데이터 로딩 실패"
                print("❌ 비교과 데이터 로딩 실패:", error)
            }
        }
    }
    
    func addActivity(type: String, title: String, hours: Int, date: Date) {
        Task {
            do {
                try await addActivityUseCase.execute(type: type, title: title, hours: hours, date: date)
                await fetchData() // 성공 시 데이터 새로고침
            } catch {
                await MainActor.run {
                    self.errorMessage = "활동 추가에 실패했습니다."
                }
            }
        }
    }
    
    // [신규] 독서 기록 추가 함수
    func addReading(title: String, author: String?, readDate: Date, hasReport: Bool) {
        Task {
            do {
                try await addReadingUseCase.execute(title: title, author: author, readDate: readDate, hasReport: hasReport)
                await fetchData() // 성공 시 데이터 새로고침
            } catch {
                await MainActor.run {
                    self.errorMessage = "독서 기록 추가에 실패했습니다."
                }
            }
        }
    }
}
