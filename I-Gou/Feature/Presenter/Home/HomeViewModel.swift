//
//  HomeViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import Foundation
import Combine

class HomeViewModel {
    // Combine을 사용해 데이터가 바뀌면 ViewController에 자동으로 알려줍니다.
    @Published var homeData: HomeData?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchHomeData() {
        // 1. 로딩 시작을 알림
        isLoading = true
        errorMessage = nil

        // 2. 서버 URL 설정
        guard let url = URL(string: "http://localhost:3000/api/home") else {
            self.errorMessage = "잘못된 URL입니다."
            self.isLoading = false
            return
        }

        // 3. URLSession으로 데이터 요청
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { // UI 업데이트는 항상 메인 스레드에서
                // 4. 로딩 종료
                self.isLoading = false

                // 5. 에러 처리
                if let error = error {
                    self.errorMessage = "데이터를 불러오는데 실패했습니다: \(error.localizedDescription)"
                    return
                }

                // 6. 데이터 변환(디코딩) 및 성공 처리
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
