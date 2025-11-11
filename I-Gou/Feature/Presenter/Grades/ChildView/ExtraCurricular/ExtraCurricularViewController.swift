//
//  ExtraCurricularViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit
import Combine

class ExtraCurricularViewController: UIViewController {
    
    private var extraCurricularView: ExtraCurricularView?
    private var viewModel: ExtraCurricularViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    // [수정] init에서 의존성 주입
    init() {
        let apiService = APIService()
        let repository = DefaultExtraCurricularRepository(apiService: apiService)
        let fetchUseCase = FetchExtraCurricularDataUseCase(repository: repository)
        let addActivityUseCase = AddActivityUseCase(repository: repository) // [추가]
        let addReadingUseCase = AddReadingUseCase(repository: repository)   // [추가]
        
        self.viewModel = ExtraCurricularViewModel(
            fetchUseCase: fetchUseCase,
            addActivityUseCase: addActivityUseCase, // [추가]
            addReadingUseCase: addReadingUseCase    // [추가]
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = ExtraCurricularView(viewModel: viewModel)
        view.delegate = self
        self.extraCurricularView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        bindViewModel()
        // [삭제] viewDidLoad에서는 첫 한 번만 호출됨
        // viewModel.fetchData()
    }
    
    // [추가] 탭을 누를 때마다(화면이 보일 때마다) 데이터를 새로고침
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchData()
    }
    
    private func bindViewModel() {
        // ViewModel의 extraData가 변경되면 View의 updateUI 함수 호출
        viewModel.$extraData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                if let data = data {
                    self?.extraCurricularView?.updateUI(with: data)
                }
            }
            .store(in: &cancellables)
        
        // [추가] isLoading 구독
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: View에 로딩 인디케이터 표시 로직 추가
                print("비교과 isLoading: \(isLoading)")
            }
            .store(in: &cancellables)
        
        // [추가] errorMessage 구독
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                }
            }.store(in: &cancellables)
    }
}

extension ExtraCurricularViewController: ExtraCurricularViewDelegate {
    func didTapAddActivity() {
        let addVC = AddActivityViewController()
        addVC.delegate = self
        self.present(addVC, animated: true)
    }
    
    // [수정] 독서 추가 화면 띄우기
    func didTapAddReading() {
        let addVC = AddReadingViewController()
        addVC.delegate = self
        self.present(addVC, animated: true)
    }
}

// '활동 추가' Delegate 구현
extension ExtraCurricularViewController: AddActivityDelegate {
    func didAddActivity(type: String, title: String, hours: Int, date: Date) {
        print("✅ 비교과 VC: '활동 추가' 데이터 받음 -> ViewModel에 전달")
        viewModel.addActivity(type: type, title: title, hours: hours, date: date)
    }
}


extension ExtraCurricularViewController: AddReadingDelegate {
    func didAddReading(title: String, author: String?, readDate: Date, hasReport: Bool) {
        print("✅ 비교과 VC: '독서 추가' 데이터 받음 -> ViewModel에 전달")
        viewModel.addReading(title: title, author: author, readDate: readDate, hasReport: hasReport)
    }
}
