//
//  NotificationView.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class NotificationsView: UIView {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    
    // ⭐️ 알림 목록이 들어갈 동적 스택뷰
    private let notificationListStackView = UIStackView()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ⭐️ 외부(VC)에서 데이터를 받아 화면을 갱신하는 함수
    func updateNotifications(items: [NotificationItem]) {
        // 1. 기존 목록 비우기
        notificationListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 2. 데이터가 없을 때 처리
        if items.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "새로운 알림이 없습니다."
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            emptyLabel.font = .systemFont(ofSize: 14)
            emptyLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
            notificationListStackView.addArrangedSubview(emptyLabel)
            return
        }
        
        // 3. 데이터가 있으면 뷰 생성해서 추가
        for item in items {
            let itemView = createNotificationItem(data: item)
            notificationListStackView.addArrangedSubview(itemView)
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        // 1. 알림 설정 카드 (디자인 유지용 - 기능 없음)
        mainStackView.addArrangedSubview(createSettingsCard())
        
        // 2. 최근 알림 카드 (동적 데이터 표시)
        mainStackView.addArrangedSubview(createRecentNotificationsCard())
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // ScrollView
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
            
            // MainStackView
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - View Factory Methods
    
    private func createSettingsCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: "bell.badge.fill", title: "알림 설정", subtitle: nil)
        
        // 디자인만 유지하고 실제 기능은 뺌 (Switch 등)
        let setting1 = createSettingItem(title: "상담 답변 알림", subtitle: "답변 등록 시 알림", isOn: true)
        let setting2 = createSettingItem(title: "입시 정보 알림", subtitle: "주요 일정 및 정보 알림", isOn: true)
        
        let stack = UIStackView(arrangedSubviews: [header, setting1, setting2])
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
            
            // ⭐️ [핵심 수정] 스택뷰 속성 강제 설정 (이게 없으면 높이가 0이 됨)
            notificationListStackView.axis = .vertical
            notificationListStackView.spacing = 12
            notificationListStackView.alignment = .fill      // 가로 꽉 채우기
            notificationListStackView.distribution = .fill   // 세로 크기 내용물에 맞춤
            notificationListStackView.translatesAutoresizingMaskIntoConstraints = false
            
            // (디버깅용) 만약 그래도 안 보이면 아래 주석을 풀어보세요. 빨간색이 보이면 스택뷰는 있는 겁니다.
            // notificationListStackView.backgroundColor = .red.withAlphaComponent(0.2)
            
            let stack = UIStackView(arrangedSubviews: [header, notificationListStackView])
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
    
    // MARK: - Helper Methods (Item Creators)
    
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
        switchControl.isEnabled = false // 아직 기능 없으므로 비활성화 (디자인용)
        
        let mainStack = UIStackView(arrangedSubviews: [labelStack, switchControl])
        mainStack.alignment = .center
        
        return mainStack
    }
    
    // ⭐️ [수정] 모델 데이터를 받아서 뷰를 만듦
    private func createNotificationItem(data: NotificationItem) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let dotView = UIView()
        // 상담 알림이면 파란색, 그 외엔 회색 등 색상 구분 가능
        dotView.backgroundColor = (data.type == "counseling") ? .systemBlue : .systemOrange
        dotView.layer.cornerRadius = 4
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        dotView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = data.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let timeLabel = UILabel()
        timeLabel.text = data.time
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .gray
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), timeLabel])
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = data.message
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 2 // 두 줄까지만 표시
        
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
