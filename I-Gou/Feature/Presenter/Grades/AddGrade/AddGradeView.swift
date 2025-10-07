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
    
    let examNameTextField = UITextField()
    let koreanScoreTextField = UITextField()
    let mathScoreTextField = UITextField()
    let englishScoreTextField = UITextField()
    
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
        examNameTextField.placeholder = "예: 1학년 1학기 중간고사"
        koreanScoreTextField.placeholder = "점수 입력"
        koreanScoreTextField.keyboardType = .numberPad
        mathScoreTextField.placeholder = "점수 입력"
        mathScoreTextField.keyboardType = .numberPad
        englishScoreTextField.placeholder = "점수 입력"
        englishScoreTextField.keyboardType = .numberPad
        
        let examNameStack = createInputStack(label: "시험명", textField: examNameTextField)
        let koreanStack = createInputStack(label: "국어", textField: koreanScoreTextField)
        let mathStack = createInputStack(label: "수학", textField: mathScoreTextField)
        let englishStack = createInputStack(label: "영어", textField: englishScoreTextField)
        
        let formStack = UIStackView(arrangedSubviews: [examNameStack, koreanStack, mathStack, englishStack])
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
