//
//  AddQuestionViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/13/25.
//

import UIKit

protocol AskQuestionDelegate: AnyObject {
    func didPostQuestion(text: String)
}

class AskQuestionViewController: UIViewController, UITextViewDelegate {

    private var askQuestionView: AskQuestionView?
    weak var delegate: AskQuestionDelegate?

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
    }
    
    private func setupNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        let postButton = UIBarButtonItem(title: "등록", style: .done, target: self, action: #selector(postButtonTapped))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = postButton
    }

    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc private func postButtonTapped() {
        guard let textView = askQuestionView?.questionTextView,
              textView.textColor != .placeholderText, // 플레이스홀더 상태가 아닐 때
              !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            print("질문 내용을 입력하세요.")
            return
        }
        
        delegate?.didPostQuestion(text: textView.text)
        self.dismiss(animated: true)
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
