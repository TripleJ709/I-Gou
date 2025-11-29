//
//  AddQuestionViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/13/25.
//

import UIKit
import Combine

protocol AskQuestionDelegate: AnyObject {
    func didPostQuestion(text: String)
}

class AskQuestionViewController: UIViewController, UITextViewDelegate {
    
    private var askQuestionView: AskQuestionView?
    private let viewModel: MyQuestionsViewModel // 주입받을 뷰모델
    private var cancellables = Set<AnyCancellable>()
    
    // ⭐️ Init (주입)
    init(viewModel: MyQuestionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = AskQuestionView()
        self.askQuestionView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "질문하기"
        setupNavigationBar()
        askQuestionView?.questionTextView.delegate = self
        bindViewModel()
    }
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        let postButton = UIBarButtonItem(title: "등록", style: .done, target: self, action: #selector(postButtonTapped))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = postButton
    }
    
    private func bindViewModel() {
        // 등록 성공 시 창 닫기
        viewModel.didPostQuestionSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func postButtonTapped() {
        guard let textView = askQuestionView?.questionTextView,
              textView.textColor != .placeholderText,
              !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        
        // ⭐️ 뷰모델을 통해 질문 등록 요청
        viewModel.postQuestion(text: textView.text)
    }
    
    // MARK: - UITextViewDelegate (플레이스홀더 처리)
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "상담받고 싶은 내용을 자세히 입력해주세요."
            textView.textColor = .placeholderText
        }
    }
}
