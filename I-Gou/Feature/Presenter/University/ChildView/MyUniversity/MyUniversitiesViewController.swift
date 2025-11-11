//
//  MyUniversitiesViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit
import Combine // 1. [추가] Combine 임포트

class MyUniversitiesViewController: UIViewController {
    
    private var myUniversitiesView: MyUniversitiesView?
    
    // 2. [추가] ViewModel과 Cancellables(구독 저장소)
    private var viewModel: MyUniversitiesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // (로딩 인디케이터 등 추가)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // 3. [추가] ViewModel을 주입받는 init
    init(viewModel: MyUniversitiesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = MyUniversitiesView()
        view.delegate = self
        self.myUniversitiesView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupLoadingUI() // 로딩 UI 설정
        bindViewModel() // 4. [추가] ViewModel 바인딩
        
        // 5. [추가] 뷰가 로드되면 ViewModel에게 '내 대학' 목록을 가져오라고 요청
        viewModel.fetchMyUniversities()
    }
    
    private func setupLoadingUI() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        // 6. [추가] '내 대학' 목록 구독
        viewModel.$myUniversities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                // 7. ViewModel에서 데이터가 오면, View의 update 함수 호출
                self?.myUniversitiesView?.updateAnalysisCard(with: items)
            }
            .store(in: &cancellables)
        
        // 8. [추가] 로딩 상태 구독
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        // 9. [추가] 에러 메시지 구독
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // nil이 아닌 에러만
            .sink { [weak self] message in
                // (실제 앱에서는 Alert 팝업 등을 띄워주세요)
                print("Error: \(message)")
            }
            .store(in: &cancellables)
        
        viewModel.didSaveUniversity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                // 11. 저장이 완료되면 (즉, 모달이 닫히면)
                // '내 대학' 목록을 새로고침합니다.
                self?.viewModel.fetchMyUniversities()
            }
            .store(in: &cancellables)
    }
}

// 10. [수정] 델리게이트가 'UniversityItem' 모델을 사용
extension MyUniversitiesViewController: MyUniversitiesViewDelegate {
    func didSelectUniversity(_ university: UniversityItem) {
        print("\(university.universityName) 선택됨")
        let detailVC = UniversityDetailViewController()
        detailVC.universityData = university
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
