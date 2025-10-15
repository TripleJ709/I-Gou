//
//  PlannerViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit
import Combine

class PlannerViewController: UIViewController {

    private var plannerView: PlannerView?
    private var viewModel: PlannerViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDependencies() // 의존성 설정
        setupView()
        bindViewModel()
        
        viewModel?.fetchPlannerData()
    }
    
    // MARK: - Setup
    
    // [추가] 의존성 주입을 담당하는 메서드
    private func setupDependencies() {
        // Data Layer
        let apiService = APIService()
        let scheduleRepository = DefaultScheduleRepository(apiService: apiService)
        
        // Domain Layer
        let fetchUseCase = FetchPlannerDataUseCase(repository: scheduleRepository)
        let addUseCase = AddScheduleUseCase(repository: scheduleRepository)
        
        // Presentation Layer
        self.viewModel = PlannerViewModel(fetchPlannerDataUseCase: fetchUseCase, addScheduleUseCase: addUseCase)
    }
    
    private func setupView() {
        let plannerView = PlannerView()
        plannerView.delegate = self
        self.plannerView = plannerView
        self.view = plannerView
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func bindViewModel() {
        // ViewModel의 @Published 프로퍼티들을 구독하여 UI 업데이트
        viewModel?.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.plannerView?.setLoading(isLoading)
            }.store(in: &cancellables)
        
        viewModel?.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                }
            }.store(in: &cancellables)

        viewModel?.$plannerData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                if let data = data {
                    self?.plannerView?.updateUI(with: data)
                }
            }.store(in: &cancellables)
    }
}

// MARK: - Delegates
extension PlannerViewController: PlannerViewDelegate {
    func didTapAddScheduleButton() {
        let addScheduleVC = AddScheduleViewController()
        addScheduleVC.delegate = self
        self.present(addScheduleVC, animated: true)
    }
}

extension PlannerViewController: AddScheduleDelegate {
    func didAddDailySchedule(title: String, time: Date) {
        viewModel?.addDailySchedule(title: title, time: time)
    }
    
    func didAddDeadline(title: String, date: Date) {
        viewModel?.addDeadline(title: title, date: date)
    }
}
