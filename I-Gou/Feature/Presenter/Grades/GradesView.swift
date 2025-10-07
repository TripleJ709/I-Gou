//
//  GradesView.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class GradesView: UIView {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    
    // ViewController에서 접근할 수 있도록 버튼들을 프로퍼티로 선언
    let internalGradesButton = GradesView.createSegmentButton(title: "내신 성적", isSelected: true)
    let mockExamButton = GradesView.createSegmentButton(title: "모의고사", isSelected: false)
    let extraCurricularButton = GradesView.createSegmentButton(title: "비교과", isSelected: false)
    
    // 자식 뷰 컨트롤러의 뷰가 들어올 컨테이너
    let contentContainerView = UIView()
    
    weak var delegate: GradesViewDelegate?
    
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
        // 기본 뷰 설정
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 뷰 계층 설정
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        // 메인 스택뷰에 공통 UI와 컨테이너 뷰 추가
        mainStackView.addArrangedSubview(createHeaderView())
        mainStackView.addArrangedSubview(createSummaryCards())
        mainStackView.addArrangedSubview(createSegmentedControl())
        mainStackView.addArrangedSubview(contentContainerView)
        
        // 레이아웃 설정
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - View Factory Methods
    
    private func createHeaderView() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "성적 관리"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "내신 및 모의고사 성적 현황"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("+ 성적 입력", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        addButton.backgroundColor = .black
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 8
        addButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        addButton.addTarget(self, action: #selector(addGradeButtonTapped), for: .touchUpInside)
        
        let headerStack = UIStackView(arrangedSubviews: [labelStack, addButton])
        headerStack.alignment = .center
        headerStack.distribution = .equalCentering
        
        return headerStack
    }
    
    private func createSummaryCards() -> UIView {
        let averageCard = createSummaryItem(title: "전체 평균", value: "87.8", subtitle: "+2.5점 전 학기 대비", iconName: "arrow.up.right", iconColor: .green)
        let goalCard = createSummaryItem(title: "목표 달성률", value: "78%", subtitle: nil, iconName: "target", iconColor: .blue)
        
        let stack = UIStackView(arrangedSubviews: [averageCard, goalCard])
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }
    
    private func createSegmentedControl() -> UIView {
        let stack = UIStackView(arrangedSubviews: [internalGradesButton, mockExamButton, extraCurricularButton])
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.backgroundColor = .systemGray6
        stack.layer.cornerRadius = 8
        return stack
    }
    
    // MARK: - Helper Methods
    
    private func createSummaryItem(title: String, value: String, subtitle: String?, iconName: String, iconColor: UIColor) -> UIView {
        let card = CardView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .gray
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
        
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = iconColor
        
        let valueStack = UIStackView(arrangedSubviews: [valueLabel, UIView(), iconView])
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, valueStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        if let subtitle = subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            subtitleLabel.textColor = iconColor
            mainStack.addArrangedSubview(subtitleLabel)
        }
        
        card.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return card
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
    
    @objc private func addGradeButtonTapped() {
        delegate?.didTapAddGradeButton()
    }
}

protocol GradesViewDelegate: AnyObject {
    func didTapAddGradeButton()
}
