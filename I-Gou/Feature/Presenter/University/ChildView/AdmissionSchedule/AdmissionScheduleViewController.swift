//
//  AdmissionScheduleViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit
import Combine // 1. Combine 프레임워크 임포트

class AdmissionsScheduleViewController: UIViewController {

    private var admissionsScheduleView: AdmissionsScheduleView?
    private var viewModel: AdmissionsScheduleViewModel
    
    // 2. Combine 구독을 관리하기 위한 저장소
    private var cancellables = Set<AnyCancellable>()
    
    // (선택) 로딩 및 에러 처리를 위한 UI
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()

    // 3. 뷰컨트롤러 생성 시 ViewModel을 주입받음
    init(viewModel: AdmissionsScheduleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        // 4. View 생성 시에도 ViewModel을 주입 (AdmissionsScheduleView의 init이 viewModel을 받는다고 가정)
        let view = AdmissionsScheduleView(viewModel: self.viewModel)
        self.admissionsScheduleView = view
        self.view = view
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupLoadingAndErrorUI() // 로딩/에러 UI 설정
        bindViewModel()          // 5. ViewModel의 @Published 프로퍼티들을 구독
        viewModel.fetchData()    // 6. 데이터 로드 시작
    }
    
    /// ViewModel의 @Published 프로퍼티와 UI를 바인딩합니다.
    private func bindViewModel() {
        
        // 7. isLoading 프로퍼티를 구독하여 로딩 인디케이터 표시
        viewModel.$isLoading
            .receive(on: DispatchQueue.main) // UI 업데이트는 메인 스레드에서
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.admissionsScheduleView?.isHidden = true
                    self?.errorLabel.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables) // 구독 저장
            
        // 8. scheduleData 프로퍼티를 구독하여 View 업데이트
        viewModel.$scheduleData
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // nil이 아닌 데이터만 필터링
            .sink { [weak self] data in
                self?.admissionsScheduleView?.updateUI(with: data)
                self?.admissionsScheduleView?.isHidden = false // 데이터 왔으니 뷰 표시
            }
            .store(in: &cancellables)
            
        // 9. errorMessage 프로퍼티를 구독하여 에러 메시지 표시
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 } // nil이 아닌 에러 메시지만 필터링
            .sink { [weak self] message in
                self?.errorLabel.text = message
                self?.errorLabel.isHidden = false
                self?.admissionsScheduleView?.isHidden = true // 에러 났으니 뷰 숨김
            }
            .store(in: &cancellables)
    }
    
    /// 로딩 인디케이터와 에러 라벨을 설정합니다.
    private func setupLoadingAndErrorUI() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isHidden = true
        errorLabel.textColor = .systemRed
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
