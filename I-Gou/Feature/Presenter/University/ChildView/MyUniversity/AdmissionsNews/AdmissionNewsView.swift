//
//  AdmissionNewsView.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit

class AdmissionsNewsView: UIView {

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
        
        mainStackView.addArrangedSubview(createNewsCard())
        
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
    
    private func createNewsCard() -> CardView {
        let card = CardView()
        
        let titleLabel = UILabel()
        titleLabel.text = "최신 대입 소식"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "엄선된 대입 정보를 확인하세요"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        
        let newsItem1 = createNewsItem(
            primaryTag: "입시정보",
            secondaryTag: "중요",
            secondaryTagColor: .systemRed,
            date: "2024-09-10",
            title: "2025학년도 대학입시 주요 변경사항",
            subtitle: "정시모집 비율 확대 및 수능 출제 방향 변화"
        )
        
        let newsItem2 = createNewsItem(
            primaryTag: "모집요강",
            secondaryTag: "서울대학교",
            secondaryTagColor: .systemGray,
            date: "2024-09-08",
            title: "서울대학교 2025 수시모집 요강 발표",
            subtitle: "지역균형선발전형 선발인원 확대"
        )
        
        let newsItem3 = createNewsItem(
            primaryTag: "모집요강",
            secondaryTag: "연세대학교",
            secondaryTagColor: .systemGray,
            date: "2024-09-07",
            title: "연세대학교 활동우수형 전형 신설",
            subtitle: "비교과 활동 중심의 새로운 전형 도입"
        )
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, newsItem1, newsItem2, newsItem3])
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
    
    private func createNewsItem(primaryTag: String, secondaryTag: String?, secondaryTagColor: UIColor?, date: String, title: String, subtitle: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        // Tags and Date
        let primaryTagLabel = createTagLabel(text: primaryTag, color: .systemGray)
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .gray
        
        let topStack = UIStackView(arrangedSubviews: [primaryTagLabel])
        if let secondaryTag = secondaryTag, let tagColor = secondaryTagColor {
            let secondaryTagLabel = createTagLabel(text: secondaryTag, color: tagColor)
            topStack.addArrangedSubview(secondaryTagLabel)
        }
        topStack.addArrangedSubview(UIView())
        topStack.addArrangedSubview(dateLabel)
        topStack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray
        
        let detailButton = UIButton(type: .system)
        detailButton.setTitle("자세히 보기", for: .normal)
        detailButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        detailButton.tintColor = .gray
        detailButton.layer.cornerRadius = 15
        detailButton.layer.borderColor = UIColor.systemGray4.cgColor
        detailButton.layer.borderWidth = 1
        detailButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        detailButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        let buttonStack = UIStackView(arrangedSubviews: [UIView(), detailButton])

        let mainStack = UIStackView(arrangedSubviews: [topStack, titleLabel, subtitleLabel, buttonStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.setCustomSpacing(12, after: subtitleLabel)
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
    
    private func createTagLabel(text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        
        let container = UIView()
        container.layer.cornerRadius = 8
        
        if color == .systemRed {
            label.textColor = color
            container.backgroundColor = color.withAlphaComponent(0.1)
        } else {
            label.textColor = .darkGray
            container.backgroundColor = .systemGray4
        }
        
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
}
