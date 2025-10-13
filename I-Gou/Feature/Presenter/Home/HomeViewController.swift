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
        homeView?.delegate = self
        bindViewModel()
        viewModel.fetchHomeData()
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.$isLoading.sink { [weak self] isLoading in
            self?.homeView?.setLoading(isLoading)
        }.store(in: &cancellables)
        
        viewModel.$errorMessage.sink { [weak self] errorMessage in
            if let message = errorMessage {
                let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
        }.store(in: &cancellables)
        
        viewModel.$homeData.sink { [weak self] data in
            if let data = data {
                self?.homeView?.updateUI(with: data)
            }
        }.store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
    }
}

extension HomeViewController: HomeViewDelegate {
    
    func didTapViewAllSchedules() {
        print("전체보기 버튼 눌림 -> 플래너 탭으로 이동")
        self.tabBarController?.selectedIndex = 1
    }
    
    func didTapViewAllGrades() {
        print("상세보기 버튼 눌림 -> 성적 탭으로 이동")
        self.tabBarController?.selectedIndex = 2
    }
    
    func didSelectUniversityNews(_ newsItem: UniversityNews) {
        let detailVC = UniversityNewsDetailViewController()
        detailVC.newsItem = newsItem
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func didTapAddScheduleQuickAction() {
        print("'학습 기록' 버튼 탭됨")
        let addScheduleVC = AddScheduleViewController()
        addScheduleVC.delegate = self
        self.present(addScheduleVC, animated: true)
    }
    
    func didTapAddGradeQuickAction() {
        print("'성적 입력' 버튼 탭됨")
        let addGradeVC = AddGradeViewController()
        addGradeVC.delegate = self
        self.present(addGradeVC, animated: true)
    }
}

extension HomeViewController: AddScheduleDelegate, AddGradeDelegate {
    func didAddGrade(record: InternalGradeRecord) {
        print("홈 탭에서 새로운 내신 성적 추가됨:")
        print("- 시험명: \(record.examName)")
        print("- 국어: \(record.koreanScore), 수학: \(record.mathScore), 영어: \(record.englishScore)")
        viewModel.fetchHomeData()
    }
    
    
    func didAddSchedule(title: String, date: Date) {
        print("홈 탭에서 새로운 일정 추가: \(title)")
        viewModel.fetchHomeData()
    }
}
