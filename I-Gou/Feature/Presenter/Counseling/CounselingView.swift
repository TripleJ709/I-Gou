//
//  CounselingView.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class CounselingView: UIView {
    
    // MARK: - UI Components
    private let mainStackView = UIStackView()
    let questionButton = UIButton(type: .system)
    
    let myQuestionsButton = CounselingView.createSegmentButton(title: "내 질문", isSelected: true)
    let notificationsButton = CounselingView.createSegmentButton(title: "알림", isSelected: false)
    let faqButton = CounselingView.createSegmentButton(title: "FAQ", isSelected: false)
    weak var delegate: CounselingViewDelegate?
    
    let contentContainerView = UIView()
    
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
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mainStackView)
        self.addSubview(contentContainerView)
        mainStackView.addArrangedSubview(createHeaderView())
        mainStackView.addArrangedSubview(createSegmentedControl())
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 1. 상단 고정 영역 (헤더 + 탭 버튼)
            mainStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            // 2. 하단 컨텐츠 영역 (나머지 공간 꽉 채우기)
            contentContainerView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 20),
            contentContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor) // 바닥까지
        ])
    }
    
    // MARK: - View Factory Methods
    private func createHeaderView() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "상담 센터"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "진학 상담 및 질문 답변"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        
        self.questionButton.setTitle("질문하기", for: .normal)
        self.questionButton.setImage(UIImage(systemName: "message.fill"), for: .normal)
        self.questionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        self.questionButton.backgroundColor = .black
        self.questionButton.tintColor = .white
        self.questionButton.setTitleColor(.white, for: .normal)
        self.questionButton.layer.cornerRadius = 8
        self.questionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        self.questionButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        self.questionButton.addTarget(self, action: #selector(askQuestionButtonTapped), for: .touchUpInside)
        
        let headerStack = UIStackView(arrangedSubviews: [labelStack, self.questionButton])
        headerStack.alignment = .center
        headerStack.distribution = .equalCentering
        
        return headerStack
    }
    
    private func createSegmentedControl() -> UIView {
        let stack = UIStackView(arrangedSubviews: [myQuestionsButton, notificationsButton, faqButton])
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
    
    @objc private func askQuestionButtonTapped() {
        delegate?.didTapAskQuestionButton()
    }
    
}

protocol CounselingViewDelegate: AnyObject {
    func didTapAskQuestionButton()
}
