//
//  MyUniversitiesViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 11/11/25.
//

import Foundation
import Combine

@MainActor
class MyUniversitiesViewModel: ObservableObject {
    
    @Published var myUniversities: [UniversityItem] = []
    @Published var searchResults: [UniversitySearchResult] = []
    @Published var departmentResults: [DepartmentSearchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let didSaveUniversity = PassthroughSubject<Void, Never>()
    private var allDepartments: [DepartmentSearchResult] = []
    private let fetchMyUniversitiesUseCase: FetchMyUniversitiesUseCase
    private let searchUseCase: SearchUniversitiesUseCase
    private let fetchDepartmentsUseCase: FetchDepartmentsUseCase
    private let saveMyUniversityUseCase: SaveMyUniversityUseCase
    
    init(
        fetchMyUniversitiesUseCase: FetchMyUniversitiesUseCase,
        searchUseCase: SearchUniversitiesUseCase,
        fetchDepartmentsUseCase: FetchDepartmentsUseCase,
        saveMyUniversityUseCase: SaveMyUniversityUseCase
    ) {
        self.fetchMyUniversitiesUseCase = fetchMyUniversitiesUseCase
        self.searchUseCase = searchUseCase
        self.fetchDepartmentsUseCase = fetchDepartmentsUseCase
        self.saveMyUniversityUseCase = saveMyUniversityUseCase
    }
    
    // [추가] 4. '내 대학' 목록을 불러오는 함수 (VC가 호출)
    func fetchMyUniversities() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                // 이 UseCase는 'UniversityDataModel.swift'의 'UniversityItem' 모델을 반환해야 함
                self.myUniversities = try await fetchMyUniversitiesUseCase.execute()
            } catch {
                self.errorMessage = "'내 대학' 목록 로딩에 실패했습니다."
            }
        }
    }
    
    // 2. 대학 검색 실행
    func search(query: String) {
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                self.searchResults = try await searchUseCase.execute(query: query)
            } catch {
                self.errorMessage = "대학 검색에 실패했습니다."
            }
        }
    }
    
    // 3. 학과 검색 실행
    func fetchDepartments(university: UniversitySearchResult) {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                let departments = try await fetchDepartmentsUseCase.execute(univName: university.name)
                
                // [수정] 2. 전체 목록과 표시 목록 모두 업데이트
                self.allDepartments = departments
                self.departmentResults = departments
                
            } catch {
                self.errorMessage = "학과 검색에 실패했습니다."
            }
        }
    }
    
    func filterDepartments(query: String) {
        if query.isEmpty {
            self.departmentResults = self.allDepartments
        } else {
            self.departmentResults = self.allDepartments.filter {
                $0.majorName.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    func saveMyUniversity(university: UniversitySearchResult, department: DepartmentSearchResult) {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                try await saveMyUniversityUseCase.execute(university: university, department: department)
                didSaveUniversity.send()
                
            } catch {
                self.errorMessage = "'내 대학' 저장에 실패했습니다."
            }
        }
    }
}
