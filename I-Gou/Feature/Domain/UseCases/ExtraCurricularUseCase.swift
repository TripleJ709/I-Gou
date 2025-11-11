//
//  ExtraCurricularUseCase.swift
//  I-Gou
//
//  Created by 장주진 on 11/10/25.
//

import Foundation

class FetchExtraCurricularDataUseCase {
    private let repository: ExtraCurricularRepository
    init(repository: ExtraCurricularRepository) { self.repository = repository }
    
    func execute() async throws -> ExtraCurricularData {
        try await repository.fetchExtraCurricularData()
    }
}

class AddActivityUseCase {
    private let repository: ExtraCurricularRepository
    init(repository: ExtraCurricularRepository) { self.repository = repository }
    
    func execute(type: String, title: String, hours: Int, date: Date) async throws {
        // TODO: 유효성 검사 (예: hours가 0보다 큰지 등)
        try await repository.addActivity(type: type, title: title, hours: hours, date: date)
    }
}

class AddReadingUseCase {
    private let repository: ExtraCurricularRepository
    init(repository: ExtraCurricularRepository) { self.repository = repository }
    
    func execute(title: String, author: String?, readDate: Date, hasReport: Bool) async throws {
        try await repository.addReading(title: title, author: author, readDate: readDate, hasReport: hasReport)
    }
}
