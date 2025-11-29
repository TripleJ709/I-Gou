//
//  MyQuestionViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit
import Combine

class MyQuestionsViewController: UIViewController {

    private var myQuestionsView: MyQuestionsView?
    private let viewModel: MyQuestionsViewModel // 주입받을 뷰모델
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: MyQuestionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = MyQuestionsView()
        self.myQuestionsView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        bindViewModel()
        viewModel.fetchQuestions() // 초기 데이터 로드
    }
    
    private func bindViewModel() {
        viewModel.$questions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] questions in
                // View에 있는 updateHistory 함수 호출 (앞서 만든 코드 필요)
                self?.myQuestionsView?.updateHistory(with: questions)
            }
            .store(in: &cancellables)
    }
}
