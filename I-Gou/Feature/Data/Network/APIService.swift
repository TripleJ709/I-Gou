//
//  APIService.swift
//  I-Gou
//
//  Created by 장주진 on 10/14/25.
//

import Foundation

class APIService {
    private let baseUrl = "http://localhost:3000/api"
    
    // MARK: - Planner
    
    func fetchPlannerData() async throws -> PlannerData {
        guard let url = URL(string: "\(baseUrl)/planner") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        // JWT 토큰 추가
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let plannerData = try JSONDecoder().decode(PlannerData.self, from: data)
        return plannerData
    }
    
    func addSchedule(title: String, date: Date, type: String, priority: String?) async throws {
        guard let url = URL(string: "\(baseUrl)/schedules") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        
        let dateString = formatter.string(from: date)
        
        var body: [String: Any] = ["title": title, "date": dateString, "type": type]
        if let priority = priority {
            body["priority"] = priority
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
}
