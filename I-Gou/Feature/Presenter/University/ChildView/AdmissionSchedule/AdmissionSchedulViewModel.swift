//
//  AdmissionSchedulViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 11/11/25.
//

import Foundation
import Combine

class AdmissionsScheduleViewModel: ObservableObject {
    @Published var scheduleData: AdmissionsScheduleData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchUseCase: FetchAdmissionsScheduleUseCase

    init(fetchUseCase: FetchAdmissionsScheduleUseCase) {
        self.fetchUseCase = fetchUseCase
    }
    
    @MainActor
    func fetchData() {
        isLoading = true
        errorMessage = nil
        Task {
            defer { isLoading = false }
            do {
                self.scheduleData = try await fetchUseCase.execute()
            } catch {
                self.errorMessage = "입시 일정을 불러오는데 실패했습니다."
            }
        }
    }
}
