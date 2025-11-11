//
//  APIService.swift
//  I-Gou
//
//  Created by 장주진 on 10/14/25.
//

import Foundation

class APIService {
    private let baseUrl = "http://localhost:3000/api"
    
    // MARK: - Helper Methods
    private func addAuthHeader(to request: inout URLRequest) {
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // else {
        // 토큰이 없는 경우 에러 처리를 하거나, 로그인 화면으로 보내는 로직 추가 가능
        // }
    }
    
    // Date 객체를 서버 DB 형식(YYYY-MM-DD HH:mm:ss)에 맞는 문자열로 변환
    private func formatDateTimeForServer(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        return formatter.string(from: date)
    }
    
    // Date 객체를 서버 DB 형식(YYYY-MM-DD)에 맞는 문자열로 변환
    private func formatDateForServer(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        return formatter.string(from: date)
    }
    
    // MARK: - Authentication
    
    // 카카오 토큰으로 우리 서버에 로그인/회원가입 요청
    func loginWithKakao(accessToken: String) async throws -> String { // JWT 반환
        guard let url = URL(string: "\(baseUrl)/auth/kakao") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["accessToken": accessToken])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // 서버에서 보낸 에러 메시지를 확인 (디버깅용)
            if let errorData = String(data: data, encoding: .utf8) { print("Login Error: \(errorData)") }
            throw URLError(.badServerResponse)
        }
        
        // 서버로부터 받은 JWT 토큰 추출
        guard let responseJson = try? JSONDecoder().decode([String: String].self, from: data),
              let appToken = responseJson["token"] else {
            throw URLError(.cannotParseResponse)
        }
        return appToken
    }
    
    
    // MARK: - Home
    
    func fetchHomeData() async throws -> HomeData {
        guard let url = URL(string: "\(baseUrl)/home") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request) // JWT 추가
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(HomeData.self, from: data)
    }
    
    // MARK: - Planner
    
    func fetchPlannerData() async throws -> PlannerData {
        guard let url = URL(string: "\(baseUrl)/planner") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request) // JWT 추가
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(PlannerData.self, from: data)
    }
    
    func addSchedule(title: String, date: Date, type: String, priority: String?) async throws {
        guard let url = URL(string: "\(baseUrl)/schedules") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request) // JWT 추가
        
        // DB DATETIME 형식에 맞게 변환
        let dateString = formatDateTimeForServer(date)
        
        var body: [String: Any?] = ["title": title, "date": dateString, "type": type, "priority": priority]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Grades
    
    // 내신 성적 조회 (차트용)
    func fetchInternalGrades() async throws -> [SubjectScoreData] {
        guard let url = URL(string: "\(baseUrl)/grades/internal") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([SubjectScoreData].self, from: data)
    }
    
    // 모의고사 성적 조회 (차트용)
    func fetchMockGrades() async throws -> [MockExamScoreData] {
        guard let url = URL(string: "\(baseUrl)/grades/mock") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([MockExamScoreData].self, from: data)
    }
    
    // 새로운 성적 추가 (한 과목씩)
    func addGrade(examType: String, examName: String, subject: String, score: Int, gradeLevel: String?, examDate: Date) async throws {
        guard let url = URL(string: "\(baseUrl)/grades") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
        // DB DATE 형식에 맞게 변환
        let examDateString = formatDateForServer(examDate)
        
        let requestBody = AddGradeRequest(
            examType: examType,
            examName: examName,
            subjectName: subject,
            score: score,
            gradeLevel: gradeLevel,
            examDate: examDateString
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchGradeDistribution() async throws -> [GradeDistributionResponse] {
        guard let url = URL(string: "\(baseUrl)/grades/distribution") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request) // JWT 추가
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([GradeDistributionResponse].self, from: data)
    }
    
    func fetchMockRecentResults() async throws -> [MockExamRecentResult] {
        guard let url = URL(string: "\(baseUrl)/grades/mock/recent") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request) // JWT 추가
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([MockExamRecentResult].self, from: data)
    }
    
    func fetchExtraCurricularData() async throws -> ExtraCurricularData {
        guard let url = URL(string: "\(baseUrl)/extracurricular") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request) // JWT 추가
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(ExtraCurricularData.self, from: data)
    }
    
    func addActivity(requestBody: AddActivityRequest) async throws {
        guard let url = URL(string: "\(baseUrl)/activities") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // [신규] 독서 기록 추가
    func addReading(requestBody: AddReadingRequest) async throws {
        guard let url = URL(string: "\(baseUrl)/reading") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // [신규] 입시 일정 조회
    func fetchAdmissionsSchedule() async throws -> AdmissionsScheduleData {
        guard let url = URL(string: "\(baseUrl)/university/schedule") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request) // JWT 추가
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(AdmissionsScheduleData.self, from: data)
    }
    
    func searchUniversities(query: String) async throws -> [UniversitySearchResult] {
        guard let url = URL(string: "http://localhost:3000/api/university/search") else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "query", value: query)]
        
        let request = createRequest(with: components.url!) // 4. JWT 헤더 포함
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([UniversitySearchResult].self, from: data)
    }
    
    // 5. [추가] 학과 검색 API 호출 함수
    func fetchDepartments(univName: String) async throws -> [DepartmentSearchResult] {
        guard let url = URL(string: "http://localhost:3000/api/university/departments") else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "univName", value: univName)]
        
        let request = createRequest(with: components.url!) // 4. JWT 헤더 포함
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([DepartmentSearchResult].self, from: data)
    }
    
    func fetchMyUniversities() async throws -> [UniversityItem] {
        // 3. 백엔드에 새로 만들 '내 대학' 목록 API 엔드포인트
        guard let url = URL(string: "http://localhost:3000/api/university/my") else {
            throw URLError(.badURL)
        }
        
        // 4. JWT 토큰을 포함한 요청 생성
        let request = createRequest(with: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // 5. 서버에서 받은 '내 대학' 목록(JSON)을 'UniversityItem' 배열로 디코딩
        return try JSONDecoder().decode([UniversityItem].self, from: data)
    }
    
    // 4. [추가] '입시 소식' 탭 - 뉴스 API 호출 함수
    func fetchNews() async throws -> [NewsItem] {
        guard let url = URL(string: "http://localhost:3000/api/university/news") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(with: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // [추가] 1. ⭐️ 서버에서 받은 원본 데이터를 Xcode 콘솔에 출력
        if let dataString = String(data: data, encoding: .utf8) {
            print("--- ⭐️ [APIService] /api/university/news가 받은 원본 데이터 ⭐️ ---")
            print(dataString)
            print("-------------------------------------------------------------")
        }
        
        // [추가] 2. ⭐️ HTTP 상태 코드도 확인 (200이 아닐 경우)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("🚨 [APIService] 서버가 200 OK가 아닌 상태 코드 반환: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        do {
            // 3. 디코딩 시도
            return try JSONDecoder().decode([NewsItem].self, from: data)
        } catch {
            // 4. ⭐️ 디코딩 실패 시, '정확한' 에러 사유를 출력
            print("🚨🚨🚨 [APIService] 'NewsItem' 디코딩 실패! 🚨🚨🚨")
            print("에러: \(error)")
            throw error // 에러를 ViewModel로 다시 던짐
        }
    }
    
    func saveMyUniversity(university: UniversitySearchResult, department: DepartmentSearchResult) async throws -> SaveUniversityResponse {
        
        guard let url = URL(string: "http://localhost:3000/api/university/my") else {
            throw URLError(.badURL)
        }
        
        // 4. 서버로 보낼 Request Body 객체 생성
        let body = SaveUniversityRequest(
            universityName: university.name,
            location: university.location,
            department: department.majorName,
            majorSeq: department.majorSeq
        )
        
        // 5. POST 요청 생성
        var request = createRequest(with: url) // createRequest가 JWT 헤더를 넣어준다고 가정
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body) // body를 JSON으로 인코딩
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(SaveUniversityResponse.self, from: data)
    }
    
    // 6. [추가] JWT 토큰을 포함한 URLRequest 생성 헬퍼
    // (이 함수가 이미 있다면, 기존 함수를 재사용하세요)
    private func createRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        
        // 1. [수정] 키체인 서비스에서 저장된 토큰을 가져옵니다.
        //    토큰이 없으면 빈 문자열("")이 됩니다.
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc2Mjg3NzU4NiwiZXhwIjoxNzYyODgxMTg2fQ.Vd1_MONlF0iaspScn6KGYJXiiCJDFvsUv9hTWb860HQ"
        
        // 2. [수정] "YOUR_JWT_TOKEN" 대신 실제 토큰을 헤더에 삽입
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // 3. (POST 요청을 위해) httpMethod 설정은 여기서 제거합니다.
        // request.httpMethod = "GET"  <-- 이 줄 삭제
        
        return request
    }
}
