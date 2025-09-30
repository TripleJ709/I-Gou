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

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "데이터를 불러오는데 실패했습니다: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.errorMessage = "데이터가 없습니다."
                    return
                }
                do {
                    self.homeData = try JSONDecoder().decode(HomeData.self, from: data)
                } catch {
                    self.errorMessage = "데이터 형식이 잘못되었습니다."
                }
            }
        }.resume()
    }
}
