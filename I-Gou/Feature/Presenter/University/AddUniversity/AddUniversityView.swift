//
//  AddUniversityView.swift
//  I-Gou
//
//  Created by 장주진 on 10/7/25.
//

import UIKit

// 1. [추가] ⭐️ 탭 이벤트를 VC로 전달할 델리게이트 프로토콜
protocol AddUniversityViewDelegate: AnyObject {
    func didSelectUniversity(_ university: UniversitySearchResult)
    func didSelectDepartment(_ department: DepartmentSearchResult)
}

class AddUniversityView: UIView {

    let searchBar = UISearchBar()
    let resultsStackView = UIStackView()
    
    // 2. [추가] ⭐️ 델리게이트 프로퍼티
    weak var delegate: AddUniversityViewDelegate?

    // 3. [추가] ⭐️ 현재 결과 목록을 저장 (탭 이벤트 처리를 위해)
    private var currentUniversities: [UniversitySearchResult] = []
    private var currentDepartments: [DepartmentSearchResult] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        searchBar.placeholder = "대학 이름으로 검색"
        searchBar.searchBarStyle = .prominent
         
        resultsStackView.axis = .vertical
        resultsStackView.spacing = 10
         
        // 4. [제거] ⭐️ 가짜 검색 결과 제거
        // let result1 = createResultButton(title: "서울대학교")
        // ...
         
        let mainStack = UIStackView(arrangedSubviews: [searchBar, resultsStackView, UIView()])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
         
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16), // 상단 여백
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    // 5. [추가] ⭐️ 대학 검색 결과로 UI 업데이트
    func updateResults(universities: [UniversitySearchResult]) {
        self.currentUniversities = universities
        self.currentDepartments = [] // 학과 목록 초기화
        
        // 스택뷰 비우기
        resultsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 검색 결과가 없으면 라벨 표시 (옵션)
        if universities.isEmpty {
            resultsStackView.addArrangedSubview(createEmptyLabel("검색 결과가 없습니다."))
        } else {
            for (index, univ) in universities.enumerated() {
                // 'location' 정보도 함께 표시
                let button = createResultButton(title: univ.name, subtitle: univ.location)
                button.tag = index // 탭 시 index 참조
                button.addTarget(self, action: #selector(universityButtonTapped(_:)), for: .touchUpInside)
                resultsStackView.addArrangedSubview(button)
            }
        }
    }
    
    // 6. [추가] ⭐️ 학과 검색 결과로 UI 업데이트
    func updateResults(departments: [DepartmentSearchResult]) {
        self.currentUniversities = [] // 대학 목록 초기화
        self.currentDepartments = departments
        
        resultsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if departments.isEmpty {
            resultsStackView.addArrangedSubview(createEmptyLabel("학과 정보가 없습니다."))
        } else {
            for (index, dept) in departments.enumerated() {
                let button = createResultButton(title: dept.majorName, subtitle: nil) // 학과는 부제목 없음
                button.tag = index // 탭 시 index 참조
                button.addTarget(self, action: #selector(departmentButtonTapped(_:)), for: .touchUpInside)
                resultsStackView.addArrangedSubview(button)
            }
        }
    }

    // 7. [수정] ⭐️ createResultButton (대학/학과 공용)
    private func createResultButton(title: String, subtitle: String?) -> UIButton {
        let button = UIButton(type: .system)
        
        // 버튼 타이틀을 UILabel처럼 여러 줄로 설정
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false // 버튼 탭이 스택뷰에 막히지 않도록
        
        if let subtitle = subtitle, !subtitle.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 14)
            subtitleLabel.textColor = .secondaryLabel
            stackView.addArrangedSubview(subtitleLabel)
        }
        
        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: button.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12)
        ])
        
        return button
    }
    
    // 8. [추가] ⭐️ 버튼 탭 핸들러
    @objc private func universityButtonTapped(_ sender: UIButton) {
        let selectedUniv = currentUniversities[sender.tag]
        delegate?.didSelectUniversity(selectedUniv)
    }
    
    @objc private func departmentButtonTapped(_ sender: UIButton) {
        let selectedDept = currentDepartments[sender.tag]
        delegate?.didSelectDepartment(selectedDept)
    }
    
    // 9. [추가] ⭐️ 비어있을 때 라벨
    private func createEmptyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return label
    }
}
