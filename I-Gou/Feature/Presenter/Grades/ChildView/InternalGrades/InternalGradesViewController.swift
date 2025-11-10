//
//  InternalGradesViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit
import Combine

class InternalGradesViewController: UIViewController {
    
    private var internalGradesView: InternalGradesView?
    private var viewModel: InternalGradesViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.fetchGrades()
    }
    
    override func loadView() {
        // ViewModel 인스턴스 생성 (원래는 외부에서 주입받아야 함)
        // TODO: ViewModel 생성 로직을 AppDelegate나 Coordinator로 이동 고려
        let apiService = APIService()
        let gradeRepository = DefaultGradeRepository(apiService: apiService)
        let fetchUseCase = FetchInternalGradesUseCase(repository: gradeRepository)
        let addUseCase = AddGradeUseCase(repository: gradeRepository) // AddGradeUseCase 추가
        let fetchDistributionUseCase = FetchGradeDistributionUseCase(repository: gradeRepository)
        
        // Presentation Layer
        // [⭐️ 핵심 수정 ⭐️] ViewModel 초기화 시 fetchDistributionUseCase를 전달합니다.
        self.viewModel = InternalGradesViewModel(
            fetchInternalGradesUseCase: fetchUseCase,
            addGradeUseCase: addUseCase,
            fetchGradeDistributionUseCase: fetchDistributionUseCase
        )
        
        // View 생성 시 ViewModel 전달
        let view = InternalGradesView(viewModel: viewModel)
        self.internalGradesView = view
        self.view = view
        self.view.backgroundColor = .clear
    }
    // MARK: - Setup
    private func setupDependencies() {
        // Data Layer
        let apiService = APIService()
        let gradeRepository = DefaultGradeRepository(apiService: apiService)
        // Domain Layer
        let fetchUseCase = FetchInternalGradesUseCase(repository: gradeRepository)
        let addUseCase = AddGradeUseCase(repository: gradeRepository)
        // Presentation Layer
        let fetchDistributionUseCase = FetchGradeDistributionUseCase(repository: gradeRepository)
        
        // Presentation Layer
        // [⭐️ 핵심 수정 ⭐️] ViewModel 초기화 시 fetchDistributionUseCase를 전달합니다.
        self.viewModel = InternalGradesViewModel(
            fetchInternalGradesUseCase: fetchUseCase,
            addGradeUseCase: addUseCase,
            fetchGradeDistributionUseCase: fetchDistributionUseCase
        )
    }
    
    private func setupView() {
        // [수정] View 생성 시 ViewModel 전달
        let view = InternalGradesView(viewModel: viewModel)
        self.internalGradesView = view
        self.view = view
        // 배경색 설정 등 UI 관련 초기 설정
        self.view.backgroundColor = .clear
    }
    
    // ViewModel 상태 변화 구독
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
        
        // isLoading 상태에 따라 로딩 인디케이터 처리 (선택 사항)
        // viewModel.$isLoading ...
    }
}

extension InternalGradesViewController: AddGradeDelegate {
    func didAddGrades(examType: String, examName: String, examDate: Date, grades: [GradeInputData]) {
        print("✅ InternalGradesVC: '\(examName)' (\(examType)) 성적 데이터 받음 (\(grades.count) 과목) -> ViewModel에 전달")
        
        for grade in grades {
            guard let subject = grade.subject,
                  let scoreString = grade.score, let score = Int(scoreString)
            else { continue }
            
            // [⭐️ 핵심 수정 ⭐️]
            // viewModel.addGradeRecord 호출 방식을 변경합니다.
            // tempRecord는 더 이상 필요 없습니다.
            viewModel.addGradeRecord(
                examType: examType,
                examName: examName, // examName을 직접 전달
                subject: subject,
                score: score,
                gradeLevel: grade.gradeLevel,
                examDate: examDate
            )
        }
    }
}

// TODO: InternalGradesViewModel, AddGradeUseCase, GradeRepository, APIService의
// addGradeRecord 관련 함수들이 GradeInputData (또는 유사한 형태)를 직접 받도록 수정 필요
// InternalGradeRecord는 더 이상 필요 없을 수 있음
