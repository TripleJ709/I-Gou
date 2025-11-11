//
//  ExtraCurricularView.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

protocol ExtraCurricularViewDelegate: AnyObject {
    func didTapAddActivity()
    func didTapAddReading()
}

class ExtraCurricularView: UIView {
    
    private var viewModel: ExtraCurricularViewModel
    weak var delegate: ExtraCurricularViewDelegate?
    
    // MARK: - UI Components
    private let mainStackView = UIStackView()
    
    // [수정] 각 카드 내부의 콘텐츠 스택뷰
    private let activitiesStackView = UIStackView()
    private let readingStatsStackView = UIStackView()
    private let readingListStackView = UIStackView()
    
    private let addActivityButton = ExtraCurricularView.createAddButton(title: "+ 활동 추가하기")
    private let addReadingButton = ExtraCurricularView.createAddButton(title: "+ 독서 기록 추가")

    // MARK: - Initializer
    init(viewModel: ExtraCurricularViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // [수정] ViewModel 데이터로 UI를 업데이트하는 함수
    func updateUI(with data: ExtraCurricularData) {
        
        // --- 1. 창의적 체험활동 업데이트 ---
        // activitiesStackView에서 헤더(첫 번째)와 버튼(마지막)을 제외한 모든 것을 제거
        let activityContent = activitiesStackView.arrangedSubviews.dropFirst().dropLast()
        activityContent.forEach { $0.removeFromSuperview() }

        if data.activities.isEmpty {
            let emptyLabel = ExtraCurricularView.createEmptyLabel("활동 내역이 없습니다.")
            activitiesStackView.insertArrangedSubview(emptyLabel, at: 1) // 헤더 뒤에 추가
        } else {
            var index = 1
            data.activities.forEach { activity in
                let itemView = ExtraCurricularView.createActivityItem(title: activity.type, category: "총 시간", hours: "\(activity.totalHours)시간")
                activitiesStackView.insertArrangedSubview(itemView, at: index)
                index += 1
            }
        }
        
        // --- 2. 독서 활동 통계 업데이트 ---
        readingStatsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let readCount = ExtraCurricularView.createStatusItem(value: "\(data.readingStats.totalBooks)", label: "읽은 책")
        let reportCount = ExtraCurricularView.createStatusItem(value: "\(data.readingStats.totalReports)", label: "독서 감상문")
        readingStatsStackView.addArrangedSubview(readCount)
        readingStatsStackView.addArrangedSubview(reportCount)
        
        // --- 3. 독서 목록 업데이트 ---
        // readingListStackView에서 헤더(첫 번째), 통계(두 번째), 버튼(마지막)을 제외하고 모두 제거
        let readingContent = readingListStackView.arrangedSubviews.dropFirst(2).dropLast()
        readingContent.forEach { $0.removeFromSuperview() }

        if data.readingList.isEmpty {
            readingListStackView.insertArrangedSubview(ExtraCurricularView.createEmptyLabel("독서 기록이 없습니다."), at: 2) // 헤더, 통계 뒤에 추가
        } else {
            var index = 2
            data.readingList.forEach { book in
                let itemView = ExtraCurricularView.createBookLogItem(title: book.title, details: "\(book.author ?? "") | \(book.readDate ?? "")")
                readingListStackView.insertArrangedSubview(itemView, at: index)
                index += 1
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        self.addSubview(mainStackView)
        
        // [수정] 스택뷰 기본 설정을 create...Card 함수 내부로 이동하거나 여기서 설정
        activitiesStackView.axis = .vertical
        activitiesStackView.spacing = 12
        activitiesStackView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout 명시

        readingStatsStackView.distribution = .fillEqually
        readingStatsStackView.spacing = 12
        readingStatsStackView.translatesAutoresizingMaskIntoConstraints = false

        readingListStackView.axis = .vertical
        readingListStackView.spacing = 12
        readingListStackView.translatesAutoresizingMaskIntoConstraints = false

        // 각 카드 생성
        mainStackView.addArrangedSubview(createCreativeActivitiesCard())
        mainStackView.addArrangedSubview(createReadingActivitiesCard())
        
        // 버튼 액션 연결
        addActivityButton.addTarget(self, action: #selector(addActivityTapped), for: .touchUpInside)
        addReadingButton.addTarget(self, action: #selector(addReadingTapped), for: .touchUpInside)
        
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
        let header = ExtraCurricularView.createCardHeader(iconName: "figure.walk", title: "창의적 체험활동", subtitle: "봉사활동, 동아리, 진로활동 현황")
        
        // [수정] activitiesStackView에 헤더와 버튼을 미리 추가
        activitiesStackView.addArrangedSubview(header)
        activitiesStackView.addArrangedSubview(addActivityButton)
        
        card.addSubview(activitiesStackView)
        NSLayoutConstraint.activate([
            activitiesStackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            activitiesStackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            activitiesStackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            activitiesStackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }
    
    private func createReadingActivitiesCard() -> CardView {
        let card = CardView()
        let header = ExtraCurricularView.createCardHeader(iconName: "book.closed.fill", title: "독서 활동", subtitle: nil)
        
        // [수정] readingListStackView에 헤더, 통계 뷰, 버튼을 미리 추가
        readingListStackView.addArrangedSubview(header)
        readingListStackView.addArrangedSubview(readingStatsStackView)
        readingListStackView.addArrangedSubview(addReadingButton)
        
        card.addSubview(readingListStackView)
        NSLayoutConstraint.activate([
            readingListStackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            readingListStackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            readingListStackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            readingListStackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }
    
    // MARK: - @objc Methods
    
    @objc private func addActivityTapped() {
        delegate?.didTapAddActivity()
    }
    
    @objc private func addReadingTapped() {
        delegate?.didTapAddReading()
    }
    
    // MARK: - Helper Methods (static으로 변경)
    
    // [수정] static으로 변경
    private static func createAddButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.tintColor = .systemGray
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    // [수정] static으로 변경
    private static func createEmptyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.textColor = .gray
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return label
    }
    
    // [수정] static으로 변경
    private static func createCardHeader(iconName: String, title: String, subtitle: String?) -> UIView {
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
    
    // [수정] static으로 변경
    private static func createActivityItem(title: String, category: String, hours: String) -> UIView {
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
    
    // [수정] static으로 변경
    private static func createStatusItem(value: String, label: String) -> UIView {
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
    
    // [수정] static으로 변경
    private static func createBookLogItem(title: String, details: String) -> UIView {
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
