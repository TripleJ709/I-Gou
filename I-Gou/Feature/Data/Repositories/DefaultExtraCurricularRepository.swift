//
//  DefaultExtraCurricularRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/10/25.
//

import Foundation

class DefaultExtraCurricularRepository: ExtraCurricularRepository {
    private let apiService: APIService
    init(apiService: APIService) { self.apiService = apiService }
    
    func fetchExtraCurricularData() async throws -> ExtraCurricularData {
        return try await apiService.fetchExtraCurricularData()
    }
    
    func addActivity(type: String, title: String, hours: Int, date: Date) async throws {
        let dateString = formatDateForServer(date) // APIService의 헬퍼 함수를 쓰려면 APIService를 수정해야 함. 여기서는 임시 구현.
        let requestBody = AddActivityRequest(type: type, title: title, hours: hours, activityDate: dateString)
        try await apiService.addActivity(requestBody: requestBody)
    }
    
    // [신규]
    func addReading(title: String, author: String?, readDate: Date, hasReport: Bool) async throws {
        let dateString = formatDateForServer(readDate)
        let requestBody = AddReadingRequest(title: title, author: author, readDate: dateString, hasReport: hasReport)
        try await apiService.addReading(requestBody: requestBody)
    }
    
    // [신규] APIService의 헬퍼 함수를 임시로 여기에도 추가 (더 좋은 방법은 날짜 포맷팅을 UseCase나 ViewModel에서 처리)
    private func formatDateForServer(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
