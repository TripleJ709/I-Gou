//
//  NotificationView.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class NotificationsView: UIView {

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
        
        mainStackView.addArrangedSubview(createSettingsCard())
        mainStackView.addArrangedSubview(createRecentNotificationsCard())
        
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
    
    private func createSettingsCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: "bell.badge.fill", title: "알림 설정", subtitle: nil)
        
        let setting1 = createSettingItem(title: "상담 답변 알림", subtitle: "답변이 등록되면 알림을 받습니다", isOn: true)
        let setting2 = createSettingItem(title: "입시 정보 알림", subtitle: "새로운 입시 정보를 알림으로 받습니다", isOn: true)
        let setting3 = createSettingItem(title: "일정 알림", subtitle: "중요한 입시 일정을 미리 알림으로 받습니다", isOn: true)
        
        let stack = UIStackView(arrangedSubviews: [header, setting1, setting2, setting3])
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
    
    private func createRecentNotificationsCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: nil, title: "최근 알림", subtitle: "놓친 알림이 없는지 확인하세요")
        
        let notification1 = createNotificationItem(title: "진학 상담 답변이 도착했습니다", subtitle: "수시 지원 전략 관련 상담에 대한 답변을 확인하세요", time: "1시간 전")
        let notification2 = createNotificationItem(title: "새로운 입시 정보가 있습니다", subtitle: "2025학년도 대입 전형 변경사항을 확인하세요", time: "3시간 전")
        let notification3 = createNotificationItem(title: "학습 플래너 알림", subtitle: "오늘 계획한 수학 문제집 풀이를 완료하세요", time: "5시간 전")
        
        let stack = UIStackView(arrangedSubviews: [header, notification1, notification2, notification3])
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
    
    private func createSettingItem(title: String, subtitle: String, isOn: Bool) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .gray
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        
        let switchControl = UISwitch()
        switchControl.isOn = isOn
        
        let mainStack = UIStackView(arrangedSubviews: [labelStack, switchControl])
        mainStack.alignment = .center
        
        return mainStack
    }
    
    private func createNotificationItem(title: String, subtitle: String, time: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let dotView = UIView()
        dotView.backgroundColor = .systemBlue
        dotView.layer.cornerRadius = 4
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        dotView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .gray
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), timeLabel])
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray
        
        let textStack = UIStackView(arrangedSubviews: [headerStack, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [dotView, textStack])
        mainStack.alignment = .top
        mainStack.spacing = 12
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
