//
//  UniversityUseCase.swift
//  I-Gou
//
//  Created by 장주진 on 11/11/25.
//

import Foundation

class FetchAdmissionsScheduleUseCase {
    private let repository: UniversityRepository
    init(repository: UniversityRepository) { self.repository = repository }
    
    func execute() async throws -> AdmissionsScheduleData {
        try await repository.fetchAdmissionsSchedule()
    }
}

class SearchUniversitiesUseCase {
    private let repository: UniversityRepository
    init(repository: UniversityRepository) { self.repository = repository }
     
    func execute(query: String) async throws -> [UniversitySearchResult] {
        return try await repository.searchUniversities(query: query)
    }
}

class FetchDepartmentsUseCase {
    private let repository: UniversityRepository
    init(repository: UniversityRepository) { self.repository = repository }
     
    func execute(univName: String) async throws -> [DepartmentSearchResult] {
        return try await repository.fetchDepartments(univName: univName)
    }
}

class FetchMyUniversitiesUseCase {
    private let repository: UniversityRepository
    init(repository: UniversityRepository) { self.repository = repository }
    
    // 2. 이 UseCase는 'UniversityItem' 모델을 반환해야 합니다.
    func execute() async throws -> [UniversityItem] {
        return try await repository.fetchMyUniversities()
    }
}

class FetchNewsUseCase {
    private let repository: UniversityRepository
    init(repository: UniversityRepository) { self.repository = repository }
    
    func execute() async throws -> [NewsItem] {
        return try await repository.fetchNews()
    }
}

class SaveMyUniversityUseCase {
    private let repository: UniversityRepository
    init(repository: UniversityRepository) { self.repository = repository }
    
    func execute(university: UniversitySearchResult, department: DepartmentSearchResult) async throws {
        try await repository.saveMyUniversity(university: university, department: department)
    }
}
