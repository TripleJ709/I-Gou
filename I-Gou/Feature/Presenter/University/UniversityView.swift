//
//  UniversityView.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit

class UniversityView: UIView {
    
    // MARK: - UI Components
    private let mainStackView = UIStackView()
    
    let myUniversityButton = UniversityView.createSegmentButton(title: "내 대학", isSelected: true)
    let admissionsNewsButton = UniversityView.createSegmentButton(title: "입시 소식", isSelected: false)
    let admissionsScheduleButton = UniversityView.createSegmentButton(title: "입시 일정", isSelected: false)
    
    let contentContainerView = UIView()
    let addFavoriteButton = UIButton(type: .system)
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        // 3. [수정] mainStackView는 헤더/검색/탭만 포함
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. [수정] self.addSubview로 바로 추가
        self.addSubview(mainStackView)
        self.addSubview(contentContainerView) // 5. [수정] contentContainerView도 self에 바로 추가
        
        mainStackView.addArrangedSubview(createHeaderView())
        mainStackView.addArrangedSubview(createSearchBar())
        mainStackView.addArrangedSubview(createSegmentedControl())
        
        // 6. [제거] ⭐️ contentContainerView를 mainStackView에서 제거
        // mainStackView.addArrangedSubview(contentContainerView)
        
        setupLayout()
    }
    
    // 7. [수정] ⭐️ setupLayout 수정
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 8. mainStackView: 상단, 좌우에 고정
            mainStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            // 9. contentContainerView: mainStackView '아래'부터 '화면 맨 끝'까지 꽉 채움
            contentContainerView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 20),
            contentContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - View Factory Methods
    
    private func createHeaderView() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "대학 정보"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "대입 정보 및 진학 관리"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        
        self.addFavoriteButton.setTitle("관심 대학 추가", for: .normal)
        self.addFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        self.addFavoriteButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        self.addFavoriteButton.backgroundColor = .black
        self.addFavoriteButton.tintColor = .white
        self.addFavoriteButton.setTitleColor(.white, for: .normal)
        self.addFavoriteButton.layer.cornerRadius = 8
        self.addFavoriteButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        self.addFavoriteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        
        let headerStack = UIStackView(arrangedSubviews: [labelStack, self.addFavoriteButton])
        headerStack.alignment = .center
        headerStack.distribution = .equalCentering
        
        return headerStack
    }
    
    private func createSearchBar() -> UIView {
        let searchBar = UISearchBar()
        searchBar.placeholder = "대학이나 학과를 검색하세요"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    private func createSegmentedControl() -> UIView {
        let stack = UIStackView(arrangedSubviews: [myUniversityButton, admissionsNewsButton, admissionsScheduleButton])
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.backgroundColor = .systemGray6
        stack.layer.cornerRadius = 8
        return stack
    }
    
    fileprivate static func createSegmentButton(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.layer.cornerRadius = 8
        
        if isSelected {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.gray, for: .normal)
        }
        
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
}
