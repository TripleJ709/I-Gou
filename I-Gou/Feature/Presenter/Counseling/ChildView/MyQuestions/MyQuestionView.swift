//
//  MyQuestionView.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class MyQuestionsView: UIView {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    private let historyStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
            // 스크롤뷰 설정
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(scrollView)
            scrollView.addSubview(contentView)
            
            // 메인 스택뷰 설정
            mainStackView.translatesAutoresizingMaskIntoConstraints = false
            mainStackView.axis = .vertical
            mainStackView.spacing = 20
            
            contentView.addSubview(mainStackView)
            
            // 카드 추가 (빠른 질문은 삭제했으므로 상담 내역만)
            mainStackView.addArrangedSubview(createCounselingHistoryCard())
            
            setupLayout()
        }
    
    private func setupLayout() {
            NSLayoutConstraint.activate([
                // ScrollView (화면 꽉 채움)
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
                mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0), // 상단 여백은 CounselingView에서 이미 줌
                mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
        }
    
    // MARK: - View Factory Methods
    private func createCounselingHistoryCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "상담 내역", subtitle: "지금까지의 질문과 답변을 확인하세요")
        
        // 스택뷰 설정
        historyStackView.axis = .vertical
        historyStackView.spacing = 16
        historyStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // [수정] 초기에는 비워둡니다 (또는 로딩 표시)
        // 하드코딩된 item1, item2, item3 삭제!
        
        let stack = UIStackView(arrangedSubviews: [header, historyStackView])
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
    
    func updateHistory(with questions: [CounselingQuestion]) {
        // 기존 뷰 제거 (초기화)
        historyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if questions.isEmpty {
            let label = UILabel()
            label.text = "상담 내역이 없습니다."
            label.textColor = .gray
            label.textAlignment = .center
            historyStackView.addArrangedSubview(label)
            return
        }
        
        for q in questions {
            // Enum 변환
            let statusEnum: CounselingStatus = (q.status == "answered") ? .answered : .waiting
            
            // 뷰 생성 및 추가
            let itemView = createHistoryItem(
                category: q.category,
                status: statusEnum,
                question: q.question,
                date: q.date,
                // [수정] counselor_name -> counselorName
                counselor: q.counselorName,
                answer: q.answer
            )
            historyStackView.addArrangedSubview(itemView)
        }
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
