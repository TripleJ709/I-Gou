//
//  HomeViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import Foundation
import Combine

class HomeViewModel {
    @Published var homeData: HomeData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchHomeData() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://localhost:3000/api/home") else {
            self.errorMessage = "잘못된 URL입니다."
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("JWT를 추가했습니다: \(token)")
        } else {
            self.errorMessage = "로그인 토큰이 없습니다. 다시 로그인해주세요."
            self.isLoading = false
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "데이터를 불러오는데 실패했습니다: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    self.errorMessage = "서버 인증에 실패했습니다 (코드: \(httpResponse.statusCode)). 토큰이 유효한지 확인하세요."
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "데이터가 없습니다."
                    return
                }
                
                do {
                    self.homeData = try JSONDecoder().decode(HomeData.self, from: data)
                } catch let decodingError {
                    self.errorMessage = "데이터 형식이 잘못되었습니다."
                    print("디코딩 에러: \(decodingError)")
                }
            }
        }.resume()
    }
}
