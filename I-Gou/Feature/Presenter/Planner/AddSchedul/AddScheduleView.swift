//
//  AddScheduleView.swift
//  I-Gou
//
//  Created by 장주진 on 10/1/25.
//

import UIKit

class AddScheduleView: UIView {

    let cancelButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    
    // [수정] UI 요소들 추가 및 변경
    let typeSegmentedControl = UISegmentedControl(items: ["일일 일정", "마감일"])
    let titleTextField = UITextField()
    
    // '일일 일정' 입력 폼
    let startTimePicker = UIDatePicker()
    private let scheduleInputStack = UIStackView()

    // '마감일' 입력 폼
    let deadlineDatePicker = UIDatePicker()
    private let deadlineInputStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Navigation Bar
        cancelButton.setTitle("취소", for: .normal)
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        let navStack = UIStackView(arrangedSubviews: [cancelButton, UIView(), saveButton])
        
        // Type Selector
        typeSegmentedControl.selectedSegmentIndex = 0
        
        // Common Input
        titleTextField.placeholder = "제목을 입력하세요"
        titleTextField.borderStyle = .roundedRect

        // Schedule Input Form
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        scheduleInputStack.axis = .vertical
        scheduleInputStack.spacing = 12
        scheduleInputStack.addArrangedSubview(createLabel("시작 시간"))
        scheduleInputStack.addArrangedSubview(startTimePicker)
        
        // Deadline Input Form
        deadlineDatePicker.datePickerMode = .date
        deadlineDatePicker.preferredDatePickerStyle = .inline
        deadlineInputStack.axis = .vertical
        deadlineInputStack.spacing = 12
        deadlineInputStack.addArrangedSubview(createLabel("마감 날짜"))
        deadlineInputStack.addArrangedSubview(deadlineDatePicker)
        deadlineInputStack.isHidden = true // 처음에는 숨김

        // Main Stack
        let mainStack = UIStackView(arrangedSubviews: [
            navStack, typeSegmentedControl, createLabel("제목"), titleTextField, scheduleInputStack, deadlineInputStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.setCustomSpacing(24, after: typeSegmentedControl)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        // Layout
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
    
    // [추가] 세그먼트 변경 시 호출될 함수
    func switchForm(to index: Int) {
        scheduleInputStack.isHidden = (index == 1)
        deadlineInputStack.isHidden = (index == 0)
    }
    
    private func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }
}
