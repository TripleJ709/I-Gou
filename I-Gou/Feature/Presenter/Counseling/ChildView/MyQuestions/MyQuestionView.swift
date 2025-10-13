//
//  MyQuestionView.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class MyQuestionsView: UIView {

    private let mainStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        self.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(createQuickQuestionsCard())
        mainStackView.addArrangedSubview(createCounselingHistoryCard())
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // MARK: - View Factory Methods
    private func createQuickQuestionsCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "빠른 질문", subtitle: "자주 묻는 질문을 클릭하세요")
        
        let questions = [
            "수시 지원 전략이 궁금해요", "정시 준비 방법을 알고 싶어요", "학생부 관리는 어떻게 해야 하나요?",
            "모의고사 성적이 안 나와요", "진로 선택에 고민이 있어요", "면접 준비는 어떻게 해야 하나요?"
        ]
        
        let questionButtons = questions.map { createQuestionButton(title: $0) }
        
        let questionStack = UIStackView(arrangedSubviews: questionButtons)
        questionStack.axis = .vertical
        questionStack.spacing = 10
        
        let stack = UIStackView(arrangedSubviews: [header, questionStack])
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

    private func createCounselingHistoryCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "상담 내역", subtitle: "지금까지의 질문과 답변을 확인하세요")
        
        let item1 = createHistoryItem(category: "진학상담", status: .answered, question: "수시 지원 전략에 대해 상담받고 싶습니다", date: "2024-09-08", counselor: "김진학 선생님", answer: "현재 성적을 고려할 때 안전, 적정, 소신 지원을 2:4:2 비율로 구성하시는 것을 추천드립니다...")
        let item2 = createHistoryItem(category: "학생부관리", status: .answered, question: "비교과 활동이 부족한 것 같은데 어떻게 보완해야 할까요?", date: "2024-09-06", counselor: "이상담 선생님", answer: "남은 기간 동안 질보다는 양적인 측면에서 체계적으로 준비하시기 바랍니다...")
        let item3 = createHistoryItem(category: "진학상담", status: .waiting, question: "정시와 수시 중 어느 쪽에 더 집중해야 할까요?", date: "2024-09-05", counselor: nil, answer: nil)

        let stack = UIStackView(arrangedSubviews: [header, item1, item2, item3])
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
    
    private func createCardHeader(title: String, subtitle: String?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel])
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
    
    private func createQuestionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.darkGray, for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.layer.borderWidth = 1
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    enum CounselingStatus { case answered, waiting }
    private func createHistoryItem(category: String, status: CounselingStatus, question: String, date: String, counselor: String?, answer: String?) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let categoryTag = createTagLabel(text: category, color: .gray)
        let statusTag = createStatusTag(status: status)
        
        let headerStack = UIStackView(arrangedSubviews: [categoryTag, statusTag, UIView()])
        headerStack.spacing = 8
        
        let questionLabel = UILabel()
        questionLabel.text = question
        questionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .gray
        
        let questionStack = UIStackView(arrangedSubviews: [questionLabel, dateLabel])
        questionStack.axis = .vertical
        questionStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, questionStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        if let counselor = counselor, let answer = answer {
            let answerView = createAnswerView(counselor: counselor, answer: answer)
            mainStack.addArrangedSubview(answerView)
            mainStack.setCustomSpacing(12, after: questionStack)
        }
        
        container.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createStatusTag(status: CounselingStatus) -> UIView {
        let (text, iconName, color): (String, String, UIColor) = {
            switch status {
            case .answered: return ("답변완료", "checkmark.circle.fill", .systemGreen)
            case .waiting: return ("답변대기", "clock.fill", .systemGray)
            }
        }()
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = color
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = color
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.spacing = 4
        stack.alignment = .center
        
        return stack
    }
    
    private func createTagLabel(text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = color
        
        let container = UIView()
        container.layer.cornerRadius = 8
        container.layer.borderColor = color.cgColor
        container.layer.borderWidth = 1
        
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        
        return container
    }
    
    private func createAnswerView(counselor: String, answer: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 8
        
        let icon = UIImageView(image: UIImage(systemName: "person.fill"))
        icon.tintColor = .darkGray
        icon.contentMode = .scaleAspectFit
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.setContentHuggingPriority(.required, for: .vertical)
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        let counselorLabel = UILabel()
        counselorLabel.text = counselor
        counselorLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        
        let headerStack = UIStackView(arrangedSubviews: [icon, counselorLabel])
        headerStack.spacing = 6
        headerStack.alignment = .center
        
        let answerLabel = UILabel()
        answerLabel.text = answer
        answerLabel.font = .systemFont(ofSize: 14)
        answerLabel.textColor = .darkGray
        answerLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [headerStack, answerLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
}
