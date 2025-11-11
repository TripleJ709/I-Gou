//
//  UniversityRepository.swift
//  I-Gou
//
//  Created by 장주진 on 11/11/25.
//

import Foundation

protocol UniversityRepository {
    func fetchAdmissionsSchedule() async throws -> AdmissionsScheduleData
    func searchUniversities(query: String) async throws -> [UniversitySearchResult]
    func fetchDepartments(univName: String) async throws -> [DepartmentSearchResult]
    func fetchMyUniversities() async throws -> [UniversityItem]
    func fetchNews() async throws -> [NewsItem]
    func saveMyUniversity(university: UniversitySearchResult, department: DepartmentSearchResult) async throws
}
