//
//  PlannerViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 10/1/25.
//

import Foundation
import Combine

class PlannerViewModel {
    @Published var plannerData: PlannerData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseUrl = "http://localhost:3000/api"
    
    func fetchPlannerData() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseUrl)/planner") else {
            self.errorMessage = "잘못된 URL입니다."
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "데이터를 불러오는데 실패했습니다: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "데이터가 없습니다."
                    return
                }
                
                do {
                    self?.plannerData = try JSONDecoder().decode(PlannerData.self, from: data)
                } catch {
                    self?.errorMessage = "데이터 형식이 잘못되었습니다: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func addSchedule(title: String, date: Date) {
        guard let url = URL(string: "\(baseUrl)/schedules") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: date)
        
        let newScheduleData: [String: Any] = [
            "time": timeString,
            "title": title,
            "subtitle": "새로 추가된 일정",
            "tag": "학습",
            "color": "blue"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newScheduleData) else {
            self.errorMessage = "데이터를 JSON 형식으로 변환하는데 실패했습니다."
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "일정 추가에 실패했습니다: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    print("일정 추가 성공, 데이터를 새로고침합니다.")
                    self?.fetchPlannerData()
                } else {
                    self?.errorMessage = "서버에서 일정을 추가하는데 실패했습니다."
                }
            }
        }.resume()
    }
}
