//
//  AdmissionScheduleView.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit

class AdmissionsScheduleView: UIView {
    
    private var viewModel: AdmissionsScheduleViewModel
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    private let scheduleStackView = UIStackView()
    private let dDayStackView = UIStackView()
    
    init(viewModel: AdmissionsScheduleViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ViewModel 데이터로 UI를 업데이트
    func updateUI(with data: AdmissionsScheduleData) {
        // 1. 주요 일정 업데이트 (이 로직은 올바릅니다)
        scheduleStackView.arrangedSubviews.dropFirst().forEach { $0.removeFromSuperview() } // 헤더 제외 삭제
        if data.mainSchedule.isEmpty {
            scheduleStackView.addArrangedSubview(createEmptyLabel("주요 입시 일정이 없습니다."))
        } else {
            data.mainSchedule.forEach { item in
                scheduleStackView.addArrangedSubview(
                    createScheduleItem(date: item.dateLabel, title: item.title, tag: item.tag, color: colorFromString(item.color))
                )
            }
        }
        
        // 2. D-Day 알림 업데이트
        // [수정] .dropFirst()를 제거해야 합니다.
        dDayStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // 모든 자식 뷰 삭제
        if data.dDayAlerts.isEmpty {
            dDayStackView.addArrangedSubview(createEmptyLabel("D-Day 알림이 없습니다."))
        } else {
            data.dDayAlerts.forEach { item in
                dDayStackView.addArrangedSubview(
                    createDdayItem(dday: item.dDay, title: item.title, color: colorFromString(item.color))
                )
            }
        }
    }
    
    private func setupUI() {
        // 3. ⭐️ 스크롤뷰와 콘텐츠 뷰 설정
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        // 4. ⭐️ 뷰 계층: self > scrollView > contentView > mainStackView
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        scheduleStackView.axis = .vertical
        scheduleStackView.spacing = 12
        dDayStackView.axis = .horizontal
        dDayStackView.distribution = .fillEqually
        dDayStackView.spacing = 12
        
        mainStackView.addArrangedSubview(createMainScheduleCard())
        mainStackView.addArrangedSubview(createDdayCard())
        
        setupLayout()
    }
    
    // 5. [수정] ⭐️ setupLayout 수정
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 6. ⭐️ ScrollView: self(AdmissionsScheduleView)의 전체를 채움
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // 7. ⭐️ ContentView: ScrollView의 전체를 채움
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // 8. ⭐️ (중요) ContentView의 가로폭 = self의 가로폭 (세로 스크롤)
            contentView.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            // 9. ⭐️ mainStackView: ContentView의 전체를 채움 (패딩 20)
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - View Factory Methods
    
    private func createMainScheduleCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: "calendar", title: "주요 입시 일정", subtitle: "놓치면 안 되는 중요한 날짜들")
        
        scheduleStackView.addArrangedSubview(header)
        
        card.addSubview(scheduleStackView)
        scheduleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scheduleStackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            scheduleStackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            scheduleStackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            scheduleStackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }
    
    private func createDdayCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: nil, title: "D-Day 알림", subtitle: nil)
        
        // D-Day 아이템은 dDayStackView가 관리
        let mainStack = UIStackView(arrangedSubviews: [header, dDayStackView])
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
    private func colorFromString(_ color: String) -> UIColor {
        switch color {
        case "red": return .systemRed
        case "blue": return .systemBlue
        case "green": return .systemGreen
        case "purple": return .systemPurple
        default: return .gray
        }
    }
    
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
    
    private func createScheduleItem(date: String, title: String, tag: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let tagLabel = createTagView(text: tag, color: color)
        
        let mainStack = UIStackView(arrangedSubviews: [dateLabel, titleLabel, UIView(), tagLabel])
        mainStack.spacing = 16
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainStack)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 50),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            mainStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createTagView(text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = color
        label.textAlignment = .center
        
        let view = UIView()
        view.backgroundColor = color.withAlphaComponent(0.15)
        view.layer.cornerRadius = 8
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        return view
    }
    
    private func createDdayItem(dday: String, title: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        container.layer.borderColor = color.withAlphaComponent(0.5).cgColor
        container.layer.borderWidth = 1.5
        
        let ddayLabel = UILabel()
        ddayLabel.text = dday
        ddayLabel.font = .systemFont(ofSize: 24, weight: .bold)
        ddayLabel.textColor = color
        ddayLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [ddayLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 90),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createEmptyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel // 내용이 없을 때 흐린 색상
        label.textAlignment = .center
        label.numberOfLines = 0
        
        // 스택뷰가 이 라벨을 늘리지 않도록 높이를 적절히 잡아줍니다.
        // D-Day 아이템(90)이나 Schedule 아이템(50)과 비슷한 높이를 줍니다.
        label.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        return label
    }
}
