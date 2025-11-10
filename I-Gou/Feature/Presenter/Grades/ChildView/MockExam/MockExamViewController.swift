//
//  MockExamViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit
import Combine

class MockExamViewController: UIViewController {

    private var mockExamView: MockExamView?
    private var viewModel: MockExamViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    init() {
        // 의존성 주입
        let apiService = APIService()
        let gradeRepository = DefaultGradeRepository(apiService: apiService)
        let fetchUseCase = FetchMockGradesUseCase(repository: gradeRepository)
        let fetchRecentUseCase = FetchMockRecentResultsUseCase(repository: gradeRepository)
        self.viewModel = MockExamViewModel(fetchMockGradesUseCase: fetchUseCase, fetchMockRecentResultsUseCase: fetchRecentUseCase)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = MockExamView(viewModel: viewModel)
        self.mockExamView = view
        self.view = view
        self.view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.fetchAllMockData()
    }
    
    private func bindViewModel() {
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                }
            }.store(in: &cancellables)
            
        // [수정] 최근 결과 목록은 데이터가 따로 오므로, 별도로 구독하여 뷰를 업데이트
        viewModel.$recentResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                // isLoading이 끝난 후에 리스트를 업데이트하기 위해
                // barChartData가 업데이트되는 것을 함께 확인하거나
                // isLoading 상태를 체크하는 것이 더 좋습니다.
                // 여기서는 간단하게 results가 비어있지 않으면 업데이트합니다.
                if !results.isEmpty || !(self?.viewModel.isLoading ?? true) {
                    self?.mockExamView?.updateResultsList(with: results)
                }
            }.store(in: &cancellables)
    }
}
