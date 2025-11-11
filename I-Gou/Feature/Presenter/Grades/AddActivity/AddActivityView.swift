//
//  AddActivityView.swift
//  I-Gou
//
//  Created by 장주진 on 11/10/25.
//

import UIKit

class AddActivityView: UIView {

    let cancelButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    
    // TODO: 'type'은 PickerView로 만드는 것이 더 좋습니다.
    let typeTextField = UITextField()
    let titleTextField = UITextField()
    let hoursTextField = UITextField()
    let activityDatePicker = UIDatePicker()

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
        typeTextField.placeholder = "활동 종류 (예: 봉사활동, 동아리활동)"
        titleTextField.placeholder = "활동 제목 (예: 사회복지관 봉사)"
        hoursTextField.placeholder = "이수 시간 (숫자만)"
        hoursTextField.keyboardType = .numberPad
        
        // 입력 폼
        let formStack = UIStackView(arrangedSubviews: [
            createInputStack(label: "활동 종류", textField: typeTextField),
            createInputStack(label: "활동 제목", textField: titleTextField),
            createInputStack(label: "이수 시간", textField: hoursTextField)
        ])
        formStack.axis = .vertical
        formStack.spacing = 1
        
        let formContainer = UIView()
        formContainer.backgroundColor = .systemBackground
        formContainer.layer.cornerRadius = 10
        formContainer.clipsToBounds = true
        formContainer.addSubview(formStack)
        formStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Date Picker
        activityDatePicker.datePickerMode = .date
        activityDatePicker.preferredDatePickerStyle = .inline
        activityDatePicker.locale = Locale(identifier: "ko_KR")
        let dateLabel = createLabel("활동 날짜")
        
        // Main Stack
        let mainStack = UIStackView(arrangedSubviews: [navStack, formContainer, dateLabel, activityDatePicker])
        mainStack.axis = .vertical
        mainStack.spacing = 16
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
    
    private func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }
    
    private func createInputStack(label: String, textField: UITextField) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 17)
        // 라벨의 너비를 80으로 고정하여 오른쪽 텍스트 필드와 정렬을 맞춥니다.
        labelView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        // 텍스트 필드 기본 스타일 설정
        textField.borderStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [labelView, textField])
        stack.spacing = 8
        // 스택뷰 내부에 여백(padding)을 줍니다 (테두리 효과).
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        return stack
    }
}
