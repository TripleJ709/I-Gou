//
//  MyUniversityView.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit

class MyUniversitiesView: UIView {
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
        
        mainStackView.addArrangedSubview(createAnalysisCard())
        mainStackView.addArrangedSubview(createSuggestionCard())
        
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
    
    private func createAnalysisCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "합격 가능성 분석", subtitle: "현재 성적 기준 예상 합격 가능성")
        
        let uni1 = createUniversityItem(university: "서울대학교", department: "경영학과", major: "학생부종합", myScore: 88.5, requiredScore: 92, deadline: "2024-09-15", status: .challenging)
        let uni2 = createUniversityItem(university: "연세대학교", department: "경제학과", major: "학생부교과", myScore: 88.5, requiredScore: 89, deadline: "2024-09-18", status: .appropriate)
        let uni3 = createUniversityItem(university: "고려대학교", department: "경영학과", major: "학생부교과", myScore: 88.5, requiredScore: 87, deadline: "2024-09-20", status: .safe)

        let stack = UIStackView(arrangedSubviews: [header, uni1, uni2, uni3])
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
    
    private func createSuggestionCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: "chart.line.uptrend.xyaxis", title: "성적 개선 제안", subtitle: nil)
        
        let suggestion1 = createSuggestionItem(iconName: "info.circle.fill", text: "수학 성적 향상 필요\n목표 대학 합격을 위해 수학 성적을 3점 향상시키세요", color: .systemBlue)
        let suggestion2 = createSuggestionItem(iconName: "book.closed.fill", text: "비교과 활동 보완\n봉사활동 시간을 20시간 더 확보하면 도움이 됩니다", color: .systemGreen)
        
        let stack = UIStackView(arrangedSubviews: [header, suggestion1, suggestion2])
        stack.axis = .vertical
        stack.spacing = 12
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
    
    private func createCardHeader(iconName: String? = nil, title: String, subtitle: String?) -> UIView {
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

    enum Status { case challenging, appropriate, safe }
    private func createUniversityItem(university: String, department: String, major: String, myScore: Float, requiredScore: Float, deadline: String, status: Status) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        // Header
        let uniLabel = UILabel()
        uniLabel.text = university
        uniLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = .systemYellow
        
        let statusTag = createStatusTag(status: status)
        
        let headerStack = UIStackView(arrangedSubviews: [uniLabel, starIcon, UIView(), statusTag])
        headerStack.spacing = 4
        headerStack.alignment = .center
        
        // Department / Major
        let deptLabel = UILabel()
        deptLabel.text = department
        deptLabel.font = .systemFont(ofSize: 14)
        
        let majorLabel = UILabel()
        majorLabel.text = major
        majorLabel.font = .systemFont(ofSize: 14)
        majorLabel.textColor = .gray
        
        let detailStack = UIStackView(arrangedSubviews: [deptLabel, majorLabel])
        
        // Score Progress
        let myScoreLabel = UILabel()
        myScoreLabel.text = "내 성적: \(myScore)"
        myScoreLabel.font = .systemFont(ofSize: 13)
        
        let requiredScoreLabel = UILabel()
        requiredScoreLabel.text = "요구 성적: \(requiredScore)"
        requiredScoreLabel.font = .systemFont(ofSize: 13)
        requiredScoreLabel.textAlignment = .right
        
        let scoreLabelStack = UIStackView(arrangedSubviews: [myScoreLabel, requiredScoreLabel])
        
        let progressView = UIProgressView()
        progressView.progress = myScore / requiredScore
        progressView.progressTintColor = (status == .safe) ? .systemGreen : .systemYellow
        progressView.trackTintColor = .systemGray4
        
        // Footer
        let deadlineLabel = UILabel()
        deadlineLabel.text = "마감일: \(deadline)"
        deadlineLabel.font = .systemFont(ofSize: 13)
        deadlineLabel.textColor = .gray
        
        let detailButton = UIButton(type: .system)
        detailButton.setTitle("상세 정보", for: .normal)
        detailButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        detailButton.tintColor = .gray
        detailButton.layer.cornerRadius = 12
        detailButton.layer.borderColor = UIColor.systemGray4.cgColor
        detailButton.layer.borderWidth = 1
        detailButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        detailButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let footerStack = UIStackView(arrangedSubviews: [deadlineLabel, UIView(), detailButton])
        footerStack.alignment = .center
        
        // Main Stack
        let mainStack = UIStackView(arrangedSubviews: [headerStack, detailStack, scoreLabelStack, progressView, footerStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
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
    
    private func createStatusTag(status: Status) -> UIView {
        let (text, iconName, color): (String, String, UIColor) = {
            switch status {
            case .challenging: return ("소신", "triangle.fill", .systemYellow)
            case .appropriate: return ("적정", "circle", .systemBlue)
            case .safe: return ("안전", "checkmark", .systemGreen)
            }
        }()
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = color
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = color
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.spacing = 4
        
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.15)
        container.layer.cornerRadius = 8
        container.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
        ])
        
        return container
    }
    
    private func createSuggestionItem(iconName: String, text: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 10
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = color
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.spacing = 12
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
}
