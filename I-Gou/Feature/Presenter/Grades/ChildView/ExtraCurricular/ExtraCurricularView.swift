//
//  ExtraCurricularView.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class ExtraCurricularView: UIView {
    
    // MARK: - UI Components
    private let mainStackView = UIStackView()
    
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
        
        self.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(createCreativeActivitiesCard())
        mainStackView.addArrangedSubview(createReadingActivitiesCard())
        
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
    
    private func createCreativeActivitiesCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: "figure.walk", title: "창의적 체험활동", subtitle: "봉사활동, 동아리, 진로활동 현황")
        
        let item1 = createActivityItem(title: "학생회 활동", category: "자율활동", hours: "45시간")
        let item2 = createActivityItem(title: "과학실험동아리", category: "동아리활동", hours: "32시간")
        let item3 = createActivityItem(title: "사회복지관 봉사", category: "봉사활동", hours: "24시간")
        let item4 = createActivityItem(title: "진로탐색 프로그램", category: "진로활동", hours: "18시간")
        
        let stack = UIStackView(arrangedSubviews: [header, item1, item2, item3, item4])
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
    
    private func createReadingActivitiesCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: "book.closed.fill", title: "독서 활동", subtitle: nil)
        
        let readCount = createStatusItem(value: "24", label: "읽은 책")
        let reportCount = createStatusItem(value: "12", label: "독서 감상문")
        
        let summaryStack = UIStackView(arrangedSubviews: [readCount, reportCount])
        summaryStack.distribution = .fillEqually
        summaryStack.spacing = 12
        
        let book1 = createBookLogItem(title: "사피엔스", details: "유발 하라리 | 2024.09.01")
        let book2 = createBookLogItem(title: "코스모스", details: "칼 세이건 | 2024.08.15")
        
        let mainStack = UIStackView(arrangedSubviews: [header, summaryStack, book1, book2])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }
    
    // MARK: - Helper Methods
    
    // ExtraCurricularView.swift
    
    private func createCardHeader(iconName: String, title: String, subtitle: String?) -> UIView {
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .label
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let headerStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        headerStack.spacing = 8
        headerStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack])
        mainStack.axis = .vertical
        mainStack.alignment = .leading
        mainStack.spacing = 4
        
        // 아이콘의 너비와 높이를 먼저 설정합니다.
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        if let subtitle = subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 14)
            subtitleLabel.textColor = .gray
            
            let spacer = UIView()
            spacer.widthAnchor.constraint(equalToConstant: 28).isActive = true
            
            let subtitleStack = UIStackView(arrangedSubviews: [spacer, subtitleLabel])
            mainStack.addArrangedSubview(subtitleStack)
        }
        
        return mainStack
    }
    
    private func createActivityItem(title: String, category: String, hours: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let categoryLabel = UILabel()
        categoryLabel.text = category
        categoryLabel.font = .systemFont(ofSize: 13)
        categoryLabel.textColor = .gray
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, categoryLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        
        let hoursLabel = UILabel()
        hoursLabel.text = hours
        hoursLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        hoursLabel.textAlignment = .right
        
        let mainStack = UIStackView(arrangedSubviews: [labelStack, hoursLabel])
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainStack)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            mainStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createStatusItem(value: String, label: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textAlignment = .center
        
        let textLabel = UILabel()
        textLabel.text = label
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = .gray
        textLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [valueLabel, textLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 80),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createBookLogItem(title: String, details: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let detailsLabel = UILabel()
        detailsLabel.text = details
        detailsLabel.font = .systemFont(ofSize: 13)
        detailsLabel.textColor = .gray
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, detailsLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
}
