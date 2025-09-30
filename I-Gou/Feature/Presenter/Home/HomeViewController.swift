//
//  HomeViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var homeView: HomeView?
    private let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        let view = HomeView()
        self.homeView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        // [추가] HomeView의 대리자를 self(HomeViewController)로 지정
        homeView?.delegate = self
        
        bindViewModel()
        viewModel.fetchHomeData()
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        // 로딩 상태에 따른 UX 처리
        viewModel.$isLoading.sink { [weak self] isLoading in
            self?.homeView?.setLoading(isLoading)
        }.store(in: &cancellables)

        // 에러 발생 시 UX 처리
        viewModel.$errorMessage.sink { [weak self] errorMessage in
            if let message = errorMessage {
                // 간단한 알림창으로 에러를 보여줌
                let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
        }.store(in: &cancellables)

        // 데이터 로딩 성공 시 UX 처리
        viewModel.$homeData.sink { [weak self] data in
            if let data = data {
                // View에 실제 데이터를 전달하여 화면을 업데이트
                self?.homeView?.updateUI(with: data)
            }
        }.store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
        // 배경색 설정은 이제 HomeView에서 관리하므로 여기서 설정할 필요가 없습니다.
        // self.view.backgroundColor = .systemGroupedBackground
    }
}

extension HomeViewController: HomeViewDelegate {
    
    func didTapViewAllSchedules() {
        print("전체보기 버튼 눌림 -> 플래너 탭으로 이동")
        // TabBarController에 접근하여 선택된 탭의 인덱스를 변경합니다.
        // 0: 홈, 1: 플래너, 2: 성적, 3: 대학, 4: 상담
        self.tabBarController?.selectedIndex = 1
    }
    
    func didTapViewAllGrades() {
        print("상세보기 버튼 눌림 -> 성적 탭으로 이동")
        // TabBarController에 접근하여 선택된 탭의 인덱스를 변경합니다.
        self.tabBarController?.selectedIndex = 2
    }
}
