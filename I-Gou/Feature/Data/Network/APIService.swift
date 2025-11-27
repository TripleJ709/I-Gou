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
    }
    
    private func formatDateTimeForServer(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        return formatter.string(from: date)
    }
    
    private func formatDateForServer(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        return formatter.string(from: date)
    }
    
    // MARK: - Authentication
    func loginWithKakao(accessToken: String) async throws -> String {
        guard let url = URL(string: "\(baseUrl)/auth/kakao") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["accessToken": accessToken])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let errorData = String(data: data, encoding: .utf8) { print("Login Error: \(errorData)") }
            throw URLError(.badServerResponse)
        }
        
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
        addAuthHeader(to: &request)
        
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
        addAuthHeader(to: &request)
        
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
        addAuthHeader(to: &request)
        
        let dateString = formatDateTimeForServer(date)
        
        var body: [String: Any?] = ["title": title, "date": dateString, "type": type, "priority": priority]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Grades
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
    
    func addGrade(examType: String, examName: String, subject: String, score: Int, gradeLevel: String?, examDate: Date) async throws {
        guard let url = URL(string: "\(baseUrl)/grades") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        addAuthHeader(to: &request)
        
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
        addAuthHeader(to: &request)
        
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
        addAuthHeader(to: &request)
        
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
        addAuthHeader(to: &request)
        
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
    
    // MARK: - university
    func fetchAdmissionsSchedule() async throws -> AdmissionsScheduleData {
        guard let url = URL(string: "\(baseUrl)/university/schedule") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        addAuthHeader(to: &request)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(AdmissionsScheduleData.self, from: data)
    }
    
    func searchUniversities(query: String) async throws -> [UniversitySearchResult] {
        // [수정] URL이 올바른지 확인
        guard let url = URL(string: "http://localhost:3000/api/university/search") else {
            print("❌ [iOS] URL 생성 실패")
            throw URLError(.badURL)
        }
        
        // [추가] 2번 로그: 요청을 보내기 직전
        print("2️⃣ [iOS] 서버로 요청 보냄: \(url.absoluteString) / 검색어: \(query)")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "query", value: query)]
        
        let request = createRequest(with: components.url!)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // [추가] 3번 로그: 응답이 왔는지 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("3️⃣ [iOS] 서버 응답 코드: \(httpResponse.statusCode)")
            }
            
            // 데이터가 비어있지 않은지 확인
            if let str = String(data: data, encoding: .utf8) {
                print("4️⃣ [iOS] 서버 응답 데이터: \(str)")
            }
            
            return try JSONDecoder().decode([UniversitySearchResult].self, from: data)
        } catch {
            // [추가] 에러 로그
            print("🚨 [iOS] 에러 발생: \(error)")
            throw error
        }
    }
    
    func fetchDepartments(univName: String) async throws -> [DepartmentSearchResult] {
        guard let url = URL(string: "http://localhost:3000/api/university/departments") else {
            throw URLError(.badURL)
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "univName", value: univName)]
        
        let request = createRequest(with: components.url!)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([DepartmentSearchResult].self, from: data)
    }
    
    func fetchMyUniversities() async throws -> [UniversityItem] {
        guard let url = URL(string: "http://localhost:3000/api/university/my") else {
            throw URLError(.badURL)
        }
        let request = createRequest(with: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([UniversityItem].self, from: data)
    }
    
    func fetchNews() async throws -> [NewsItem] {
        guard let url = URL(string: "http://localhost:3000/api/university/news") else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(with: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let dataString = String(data: data, encoding: .utf8) {
            print("--- ⭐️ [APIService] /api/university/news가 받은 원본 데이터 ⭐️ ---")
            print(dataString)
            print("-------------------------------------------------------------")
        }
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("🚨 [APIService] 서버가 200 OK가 아닌 상태 코드 반환: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode([NewsItem].self, from: data)
        } catch {
            print("🚨🚨🚨 [APIService] 'NewsItem' 디코딩 실패! 🚨🚨🚨")
            print("에러: \(error)")
            throw error
        }
    }
    
    func saveMyUniversity(university: UniversitySearchResult, department: DepartmentSearchResult) async throws -> SaveUniversityResponse {
        guard let url = URL(string: "http://localhost:3000/api/university/my") else {
            throw URLError(.badURL)
        }
        let body = SaveUniversityRequest(
            universityName: university.name,
            location: university.location,
            department: department.majorName,
            majorSeq: department.majorSeq
        )

        var request = createRequest(with: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(SaveUniversityResponse.self, from: data)
    }
    
    private func createRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTc2NDIzNTkzNywiZXhwIjoxNzk1NzcxOTM3fQ.POsS83WIVRAt44HZDXv6qQzPR9HbU6W_H5WoqzeK1Yg"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
