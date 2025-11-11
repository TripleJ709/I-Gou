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
}
