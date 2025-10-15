//
//  PlannerViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 10/1/25.
//

import Foundation
import Combine

class PlannerViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI가 구독할 상태)
    @Published var plannerData: PlannerData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Use Cases (비즈니스 로직)
    private let fetchPlannerDataUseCase: FetchPlannerDataUseCase
    private let addScheduleUseCase: AddScheduleUseCase

    // MARK: - Initializer (의존성 주입)
    init(fetchPlannerDataUseCase: FetchPlannerDataUseCase, addScheduleUseCase: AddScheduleUseCase) {
        self.fetchPlannerDataUseCase = fetchPlannerDataUseCase
        self.addScheduleUseCase = addScheduleUseCase
    }

    // MARK: - Public Methods
    
    @MainActor
    func fetchPlannerData() {
        isLoading = true
        
        Task {
            do {
                let data = try await fetchPlannerDataUseCase.execute()
                self.plannerData = data
            } catch {
                self.errorMessage = "데이터를 불러오는데 실패했습니다: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
    
    func addDailySchedule(title: String, time: Date) {
        Task {
            do {
                try await addScheduleUseCase.execute(dailySchedule: title, time: time)
                await fetchPlannerData()
            } catch {
                await MainActor.run {
                    self.errorMessage = "일정 추가에 실패했습니다."
                }
            }
        }
    }
    
    func addDeadline(title: String, date: Date) {
        Task {
            do {
                try await addScheduleUseCase.execute(deadline: title, date: date)
                await fetchPlannerData()
            } catch {
                await MainActor.run {
                    self.errorMessage = "마감일 추가에 실패했습니다."
                }
            }
        }
    }
}
