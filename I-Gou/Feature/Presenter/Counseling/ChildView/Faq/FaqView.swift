//
//  FaqView.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class FaqView: UIView {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground // 배경색 통일
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        // 메인 스택뷰 설정
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        // ⭐️ [수정] 상담 신청 카드는 삭제하고 FAQ 목록만 추가
        mainStackView.addArrangedSubview(createFaqListCard())
        
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // ScrollView (화면 전체)
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // MainStackView (패딩 추가)
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - View Factory Methods
    
    private func createFaqListCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: "questionmark.circle.fill", title: "자주 묻는 질문", subtitle: "일반적인 질문과 답변을 확인하세요")
        
        // FAQ 아이템들 (나중에 필요하면 서버에서 받아오도록 수정 가능)
        let qa1 = createQAItem(
            question: "수시 원서는 몇 개까지 넣을 수 있나요?",
            answer: "수시모집에서는 최대 6개 대학에 지원할 수 있습니다. 각 대학마다 최대 3개 전형까지 지원 가능합니다."
        )
        let qa2 = createQAItem(
            question: "정시에서 수능 최저학력기준이 뭔가요?",
            answer: "정시모집에서 대학이 요구하는 수능 성적의 최소 기준입니다. 이 기준을 만족해야 해당 대학에 지원할 수 있습니다."
        )
        let qa3 = createQAItem(
            question: "학생부종합전형에서 가장 중요한 것은 무엇인가요?",
            answer: "학업역량, 전공적합성, 인성, 발전가능성을 종합적으로 평가합니다. 특히 전공과 관련된 일관성 있는 활동이 중요합니다."
        )
        
        let stack = UIStackView(arrangedSubviews: [header, qa1, qa2, qa3])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        return card
    }

    // MARK: - Helper Methods
    
    private func createCardHeader(iconName: String?, title: String, subtitle: String?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let stack: UIStackView
        if let iconName = iconName, let icon = UIImage(systemName: iconName) {
            let iconImageView = UIImageView(image: icon)
            iconImageView.tintColor = .label
            iconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
            stack.spacing = 8
        } else {
            stack = UIStackView(arrangedSubviews: [titleLabel])
        }
        stack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [stack])
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 4
        
        if let subtitle = subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 14)
            subtitleLabel.textColor = .gray
            mainStack.addArrangedSubview(subtitleLabel)
        }
        
        return mainStack
    }
    
    private func createQAItem(question: String, answer: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let qLabel = UILabel()
        qLabel.text = "Q."
        qLabel.font = .systemFont(ofSize: 16, weight: .bold)
        qLabel.textColor = .systemBlue // 질문 강조색
        
        let questionLabel = UILabel()
        questionLabel.text = question
        questionLabel.font = .systemFont(ofSize: 16, weight: .bold)
        questionLabel.numberOfLines = 0
        
        let qStack = UIStackView(arrangedSubviews: [qLabel, questionLabel])
        qStack.spacing = 8
        qStack.alignment = .top
        
        let aLabel = UILabel()
        aLabel.text = "A."
        aLabel.font = .systemFont(ofSize: 15, weight: .bold)
        aLabel.textColor = .darkGray
        
        let answerLabel = UILabel()
        answerLabel.text = answer
        answerLabel.font = .systemFont(ofSize: 15)
        answerLabel.textColor = .darkGray
        answerLabel.numberOfLines = 0
        
        let aStack = UIStackView(arrangedSubviews: [aLabel, answerLabel])
        aStack.spacing = 8
        aStack.alignment = .top

        let mainStack = UIStackView(arrangedSubviews: [qStack, aStack])
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
}
