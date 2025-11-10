//
//  AddGradeView.swift
//  I-Gou
//
//  Created by 장주진 on 10/6/25.
//

// AddGradeView.swift
import UIKit

class AddGradeView: UIView {
    
    let cancelButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    
    let examTypeSegmentedControl = UISegmentedControl(items: ["내신", "모의고사"])
    let examNameTextField = UITextField()
    let examDatePicker = UIDatePicker()
    
    let tableView = UITableView() // 과목 입력 테이블
    let addSubjectButton = UIButton(type: .system) // 과목 추가 버튼
    
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
        
        // Exam Info Inputs
        examTypeSegmentedControl.selectedSegmentIndex = 0
        
        examNameTextField.placeholder = "예: 1학년 1학기 중간고사"
        examNameTextField.borderStyle = .roundedRect
        
        examDatePicker.datePickerMode = .date
        examDatePicker.preferredDatePickerStyle = .compact
        examDatePicker.locale = Locale(identifier: "ko_KR")
        
        let dateStack = createHorizontalStack(label: "시험 날짜", view: examDatePicker)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(GradeInputCell.self, forCellReuseIdentifier: GradeInputCell.identifier)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 사용 명시
        
        addSubjectButton.setTitle("+ 더 입력하기", for: .normal)
        addSubjectButton.titleLabel?.font = .systemFont(ofSize: 15)
        addSubjectButton.tintColor = .systemGray

        let mainStack = UIStackView(arrangedSubviews: [
            navStack,
            examTypeSegmentedControl,
            examNameTextField,
            dateStack,
            tableView, // 테이블 뷰 추가
            addSubjectButton // 버튼 추가
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.setCustomSpacing(24, after: examTypeSegmentedControl) // 그룹 간 간격 조절
        mainStack.setCustomSpacing(10, after: tableView)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        // Layout
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // 테이블 뷰 높이 제약조건 (중요: 내용에 따라 늘어나도록 설정 필요)
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 500) // 최소 높이 지정
        ])
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
