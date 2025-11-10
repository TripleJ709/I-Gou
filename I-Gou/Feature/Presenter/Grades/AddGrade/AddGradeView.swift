//
//  AddGradeView.swift
//  I-Gou
//
//  Created by 장주진 on 10/6/25.
//

// AddGradeView.swift
// AddGradeView.swift
import UIKit

class AddGradeView: UIView {
    
    let cancelButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    
    let examTypeSegmentedControl = UISegmentedControl(items: ["내신", "모의고사"])
    let examNameTextField = UITextField()
    let examDatePicker = UIDatePicker()
    
    // --- '내신'용 UI ---
    let tableView = UITableView()
    let addSubjectButton = UIButton(type: .system)
    
    // --- [신규] '모의고사'용 UI ---
    let mockExamInputStack = UIStackView() // 모의고사 입력 폼을 담을 스택뷰
    let mockKoreanScoreField = UITextField()
    let mockMathScoreField = UITextField()
    let mockEnglishScoreField = UITextField()
    let mockSearch1ScoreField = UITextField() // 탐구1
    let mockSearch2ScoreField = UITextField() // 탐구2
    let mockHistoryScoreField = UITextField() // 한국사
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // --- Navigation Bar ---
        cancelButton.setTitle("취소", for: .normal)
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        let navStack = UIStackView(arrangedSubviews: [cancelButton, UIView(), saveButton])
        
        // --- Exam Info (공통) ---
        examTypeSegmentedControl.selectedSegmentIndex = 0
        examNameTextField.placeholder = "예: 1학년 1학기 중간고사"
        examNameTextField.borderStyle = .roundedRect
        examDatePicker.datePickerMode = .date
        examDatePicker.preferredDatePickerStyle = .compact
        examDatePicker.locale = Locale(identifier: "ko_KR")
        let dateStack = createHorizontalStack(label: "시험 날짜", view: examDatePicker)
        
        // --- '내신'용 UI 설정 ---
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(GradeInputCell.self, forCellReuseIdentifier: GradeInputCell.identifier)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubjectButton.setTitle("+ 더 입력하기", for: .normal)
        addSubjectButton.titleLabel?.font = .systemFont(ofSize: 15)
        addSubjectButton.tintColor = .systemGray
        
        // --- [신규] '모의고사'용 UI 설정 ---
        mockKoreanScoreField.placeholder = "원점수"
        mockMathScoreField.placeholder = "원점수"
        mockEnglishScoreField.placeholder = "원점수"
        mockSearch1ScoreField.placeholder = "원점수"
        mockSearch2ScoreField.placeholder = "원점수"
        mockHistoryScoreField.placeholder = "원점수"
        
        let mockFormStack = UIStackView(arrangedSubviews: [
            createInputStack(label: "국어", textField: mockKoreanScoreField),
            createInputStack(label: "수학", textField: mockMathScoreField),
            createInputStack(label: "영어", textField: mockEnglishScoreField),
            createInputStack(label: "탐구(1)", textField: mockSearch1ScoreField),
            createInputStack(label: "탐구(2)", textField: mockSearch2ScoreField),
            createInputStack(label: "한국사", textField: mockHistoryScoreField)
        ])
        mockFormStack.axis = .vertical
        mockFormStack.spacing = 1
        
        let formContainer = UIView()
        formContainer.backgroundColor = .systemBackground
        formContainer.layer.cornerRadius = 10
        formContainer.clipsToBounds = true
        formContainer.addSubview(mockFormStack)
        mockFormStack.translatesAutoresizingMaskIntoConstraints = false
        
        mockExamInputStack.addArrangedSubview(formContainer) // 모의고사 폼을 스택뷰에 추가
        mockExamInputStack.isHidden = true // 처음에는 숨김
        
        // --- Main Stack ---
        let mainStack = UIStackView(arrangedSubviews: [
            navStack,
            examTypeSegmentedControl,
            examNameTextField,
            dateStack,
            tableView,          // '내신' 테이블
            addSubjectButton,   // '내신' 추가 버튼
            mockExamInputStack  // '모의고사' 폼
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.setCustomSpacing(24, after: examTypeSegmentedControl)
        mainStack.setCustomSpacing(10, after: tableView)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        // --- Layout ---
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // 모의고사 폼 레이아웃
            mockFormStack.topAnchor.constraint(equalTo: formContainer.topAnchor),
            mockFormStack.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            mockFormStack.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            mockFormStack.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor)
        ])
    }
    
    // [신규] UI 전환 함수
    func switchForm(to index: Int) {
        if index == 0 { // '내신' 선택
            tableView.isHidden = false
            addSubjectButton.isHidden = false
            mockExamInputStack.isHidden = true
            examNameTextField.placeholder = "예: 1학년 1학기 중간고사"
        } else { // '모의고사' 선택
            tableView.isHidden = true
            addSubjectButton.isHidden = true
            mockExamInputStack.isHidden = false
            examNameTextField.placeholder = "예: 3월 전국연합학력평가"
        }
    }
    
    // TextField용 헬퍼 (기존)
    private func createInputStack(label: String, textField: UITextField) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 17)
        labelView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        textField.borderStyle = .none
        textField.keyboardType = .numberPad // 모든 점수 입력은 숫자 키패드로
        
        let stack = UIStackView(arrangedSubviews: [labelView, textField])
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return stack
    }
    
    // 간단한 라벨 + 뷰 가로 배치 헬퍼
    private func createHorizontalStack(label: String, view: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 17)
        let stack = UIStackView(arrangedSubviews: [labelView, view])
        stack.spacing = 8
        return stack
    }
}
