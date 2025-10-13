//
//  AddQuestionView.swift
//  I-Gou
//
//  Created by 장주진 on 10/13/25.
//

import UIKit

class AskQuestionView: UIView {

    let questionTextView = UITextView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        questionTextView.font = .systemFont(ofSize: 16)
        questionTextView.layer.cornerRadius = 10
        questionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        questionTextView.translatesAutoresizingMaskIntoConstraints = false
        questionTextView.text = "상담받고 싶은 내용을 자세히 입력해주세요."
        questionTextView.textColor = .placeholderText

        addSubview(questionTextView)
        
        NSLayoutConstraint.activate([
            questionTextView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            questionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            questionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            questionTextView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
}
