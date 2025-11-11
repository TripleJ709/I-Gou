//
//  AddReadingViewController.swift
//  I-Gou
//
//  Created by 장주진 on 11/11/25.
//

import UIKit

// 이 컨트롤러가 완료되었을 때 ExtraCurricularViewController에게 알려주기 위한 규칙
protocol AddReadingDelegate: AnyObject {
    func didAddReading(title: String, author: String?, readDate: Date, hasReport: Bool)
}

class AddReadingViewController: UIViewController {

    weak var delegate: AddReadingDelegate?
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let titleTextField = UITextField()
    private let authorTextField = UITextField()
    private let readDatePicker = UIDatePicker()
    private let reportSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupButtonActions()
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            print("책 제목을 입력하세요.")
            // TODO: 사용자에게 알림 띄우기
            return
        }
        let author = authorTextField.text
        let readDate = readDatePicker.date
        let hasReport = reportSwitch.isOn
        
        delegate?.didAddReading(title: title, author: author, readDate: readDate, hasReport: hasReport)
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() { self.dismiss(animated: true) }
    
    private func setupButtonActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // --- UI 설정 (AddGradeView와 유사) ---
    private func setupUI() {
        cancelButton.setTitle("취소", for: .normal)
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        let navStack = UIStackView(arrangedSubviews: [cancelButton, UIView(), saveButton])
        
        titleTextField.placeholder = "책 제목 (예: 사피엔스)"
        authorTextField.placeholder = "저자 (예: 유발 하라리)"
        
        let formStack = UIStackView(arrangedSubviews: [
            createInputStack(label: "책 제목", textField: titleTextField),
            createInputStack(label: "저자", textField: authorTextField),
            createInputStack(label: "독서 감상문", switchView: reportSwitch)
        ])
        formStack.axis = .vertical
        formStack.spacing = 1 // 구분선 효과
        formStack.translatesAutoresizingMaskIntoConstraints = false

        let formContainer = UIView()
        formContainer.backgroundColor = .systemBackground
        formContainer.layer.cornerRadius = 10
        formContainer.clipsToBounds = true
        formContainer.addSubview(formStack)
        
        readDatePicker.datePickerMode = .date
        readDatePicker.preferredDatePickerStyle = .inline // 달력 스타일
        readDatePicker.locale = Locale(identifier: "ko_KR")
        let dateLabel = UILabel()
        dateLabel.text = "읽은 날짜"
        dateLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let mainStack = UIStackView(arrangedSubviews: [navStack, formContainer, dateLabel, readDatePicker])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.setCustomSpacing(24, after: navStack) // 그룹 간 간격
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        // --- Auto Layout ---
        NSLayoutConstraint.activate([
            // mainStack 레이아웃
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // formContainer 내부의 formStack 레이아웃
            formStack.topAnchor.constraint(equalTo: formContainer.topAnchor),
            formStack.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            formStack.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            formStack.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor)
        ])
    }
    
    // UITextField용 헬퍼 함수
    private func createInputStack(label: String, textField: UITextField) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 17)
        labelView.widthAnchor.constraint(equalToConstant: 100).isActive = true // 라벨 너비 고정
        
        textField.borderStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [labelView, textField])
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return stack
    }
    
    // UISwitch용 헬퍼 함수
    private func createInputStack(label: String, switchView: UISwitch) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 17)
        
        let stack = UIStackView(arrangedSubviews: [labelView, switchView])
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return stack
    }
}
