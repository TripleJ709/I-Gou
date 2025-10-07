//
//  AddGradeView.swift
//  I-Gou
//
//  Created by 장주진 on 10/6/25.
//

import UIKit

class AddGradeView: UIView {

    let cancelButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    let subjectTextField = UITextField()
    let scoreTextField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Navigation Bar Items
        cancelButton.setTitle("취소", for: .normal)
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)

        let navStack = UIStackView(arrangedSubviews: [cancelButton, UIView(), saveButton])
        
        // Input Fields
        subjectTextField.placeholder = "과목명"
        scoreTextField.placeholder = "점수"
        scoreTextField.keyboardType = .numberPad // 숫자 키패드
        
        let subjectStack = createInputStack(label: "과목", textField: subjectTextField)
        let scoreStack = createInputStack(label: "점수", textField: scoreTextField)
        
        let formStack = UIStackView(arrangedSubviews: [subjectStack, scoreStack])
        formStack.axis = .vertical
        formStack.spacing = 1
        
        let formContainer = UIView()
        formContainer.backgroundColor = .systemBackground
        formContainer.layer.cornerRadius = 10
        formContainer.clipsToBounds = true
        formContainer.addSubview(formStack)
        formStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Main Stack View
        let mainStack = UIStackView(arrangedSubviews: [navStack, formContainer])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        // Layout
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            formStack.topAnchor.constraint(equalTo: formContainer.topAnchor),
            formStack.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            formStack.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            formStack.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor)
        ])
    }
    
    private func createInputStack(label: String, textField: UITextField) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 17)
        labelView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [labelView, textField])
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return stack
    }
}
