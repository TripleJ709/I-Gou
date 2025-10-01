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
    let titleTextField = UITextField()
    let datePicker = UIDatePicker()

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
        
        // Title Text Field
        titleTextField.placeholder = "일정 제목"
        titleTextField.font = .systemFont(ofSize: 22)
        titleTextField.borderStyle = .none
        
        let textFieldContainer = UIView()
        textFieldContainer.backgroundColor = .systemBackground
        textFieldContainer.layer.cornerRadius = 10
        textFieldContainer.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false

        // Date Picker
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "ko_KR")
        
        let datePickerContainer = UIView()
        datePickerContainer.backgroundColor = .systemBackground
        datePickerContainer.layer.cornerRadius = 10
        datePickerContainer.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        // Main Stack View
        let mainStack = UIStackView(arrangedSubviews: [navStack, textFieldContainer, datePickerContainer])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        // Layout
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            titleTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor, constant: 12),
            titleTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 12),
            titleTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -12),
            titleTextField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: -12),
            
            datePicker.topAnchor.constraint(equalTo: datePickerContainer.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: datePickerContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: datePickerContainer.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: datePickerContainer.bottomAnchor)
        ])
    }
}
