//
//  DefaultUniversityRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/11/25.
//

import Foundation

class DefaultUniversityRepository: UniversityRepository {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    func fetchAdmissionsSchedule() async throws -> AdmissionsScheduleData {
        return try await apiService.fetchAdmissionsSchedule()
    }
    
    func searchUniversities(query: String) async throws -> [UniversitySearchResult] {
        return try await apiService.searchUniversities(query: query)
    }
    
    func fetchDepartments(univName: String) async throws -> [DepartmentSearchResult] {
        return try await apiService.fetchDepartments(univName: univName)
    }
    
    func fetchMyUniversities() async throws -> [UniversityItem] {
        return try await apiService.fetchMyUniversities()
    }
    
    func fetchNews() async throws -> [NewsItem] {
        return try await apiService.fetchNews()
    }
    
    func saveMyUniversity(university: UniversitySearchResult, department: DepartmentSearchResult) async throws {
        _ = try await apiService.saveMyUniversity(university: university, department: department)
    }
}
