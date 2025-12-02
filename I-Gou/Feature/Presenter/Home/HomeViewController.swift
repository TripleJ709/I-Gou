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
    private lazy var viewModel: HomeViewModel = {
        let apiService = APIService()
        let repository = DefaultHomeRepository(apiService: apiService)
        let useCase = FetchHomeDataUseCase(repository: repository)
        return HomeViewModel(fetchHomeDataUseCase: useCase)
    }()
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
        
        //임시 로그아웃
//        let logoutButton = UIBarButtonItem(title: "로그아웃", style: .plain, target: self, action: #selector(logoutButtonTapped))
//        self.navigationItem.leftBarButtonItem = logoutButton
    }
    
    @objc private func logoutButtonTapped() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        print("토큰 삭제, 로그아웃")
        
        guard let window = self.view.window else { return }
        
        let loginViewController = LoginViewController()
        window.rootViewController = loginViewController
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
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
    func didAddGrades(examType: String, examName: String, examDate: Date, grades: [GradeInputData]) {
        viewModel.fetchHomeData()
    }
    
    func didAddDailySchedule(title: String, time: Date) {
        viewModel.fetchHomeData()
    }
    
    func didAddDeadline(title: String, date: Date) {
        viewModel.fetchHomeData()
    }
}
