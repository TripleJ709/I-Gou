//
//  HomeView.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit

class HomeView: UIView {

    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

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
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(createWelcomeCard())
        mainStackView.addArrangedSubview(createNotificationCard())
        mainStackView.addArrangedSubview(createTodayScheduleCard())
        mainStackView.addArrangedSubview(createRecentGradesCard())
        mainStackView.addArrangedSubview(createUniversityNewsCard())
        mainStackView.addArrangedSubview(createQuickActionsCard())
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Card Factory Methods
    
    private func createWelcomeCard() -> UIView {
        let card = CardView()
        
        let greetingLabel = UILabel()
        greetingLabel.text = "안녕하세요, OOO! 👋"
        greetingLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        let subGreetingLabel = UILabel()
        subGreetingLabel.text = "오늘도 목표를 향해 한 걸음 더 나아가세요"
        subGreetingLabel.font = .systemFont(ofSize: 14)
        subGreetingLabel.textColor = .gray
        
        let stackView = UIStackView(arrangedSubviews: [greetingLabel, subGreetingLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        return card
    }
    
    private func createNotificationCard() -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "bell.fill", title: "알림")
        
        let notification1 = createNotificationItem(text: "2025학년도 수시모집 원서접수 시작", time: "2시간 전", color: .systemBlue)
        let notification2 = createNotificationItem(text: "11월 모의고사 성적 확인 가능", time: "1일 전", color: .systemGreen)
        let notification3 = createNotificationItem(text: "진로 상담 예약 확인", time: "2일 전", color: .systemPurple)
        
        let stackView = UIStackView(arrangedSubviews: [header, notification1, notification2, notification3])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func createTodayScheduleCard() -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "calendar", title: "오늘의 일정", actionButtonTitle: "전체보기")
        
        let schedule1 = createScheduleItem(time: "09:00", title: "국어", tagText: "수업")
        let schedule2 = createScheduleItem(time: "10:00", title: "수학", tagText: "수업")
        let schedule3 = createScheduleItem(time: "14:00", title: "진로 상담", tagText: "상담")
        let schedule4 = createScheduleItem(time: "16:00", title: "동아리 활동", tagText: "활동")
        
        let stackView = UIStackView(arrangedSubviews: [header, schedule1, schedule2, schedule3, schedule4])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func createRecentGradesCard() -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "chart.bar.xaxis", title: "최근 성적", actionButtonTitle: "상세보기")
        
        let grade1 = createGradeItem(subject: "국어", score: "88점", grade: "2등급")
        let grade2 = createGradeItem(subject: "수학", score: "92점", grade: "1등급", isHighlight: true)
        let grade3 = createGradeItem(subject: "영어", score: "85점", grade: "2등급")
        
        let stackView = UIStackView(arrangedSubviews: [header, grade1, grade2, grade3])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }

    private func createUniversityNewsCard() -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "star.fill", title: "관심 대학 소식")

        let news1 = createNewsItem(university: "서울대학교", title: "2025학년도 수시모집 합격자 발표 일정 안내", isNew: true)
        let news2 = createNewsItem(university: "연세대학교", title: "정시모집 전형계획 발표", isNew: false)
        
        let stackView = UIStackView(arrangedSubviews: [header, news1, news2])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        return card
    }
    
    private func createQuickActionsCard() -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "", title: "빠른 기능")
        
        let studyButton = createActionButton(iconName: "book.fill", title: "학습 기록")
        let gradeButton = createActionButton(iconName: "chart.line.uptrend.xyaxis", title: "성적 입력")
        
        let buttonStack = UIStackView(arrangedSubviews: [studyButton, gradeButton])
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        let mainStack = UIStackView(arrangedSubviews: [header, buttonStack])
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

    // MARK: - UI Element Helper Methods
    private func createHeaderView(iconName: String, title: String, actionButtonTitle: String? = nil) -> UIView {
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        if !iconName.isEmpty {
            iconImageView.image = UIImage(systemName: iconName)
            iconImageView.tintColor = .label
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: 22),
                iconImageView.heightAnchor.constraint(equalToConstant: 22)
            ])
        }
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let hStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        hStack.spacing = 8
        hStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [hStack])
        mainStack.alignment = .center
        
        if let actionTitle = actionButtonTitle {
            let actionButton = UIButton(type: .system)
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.titleLabel?.font = .systemFont(ofSize: 14)
            actionButton.tintColor = .gray
            mainStack.addArrangedSubview(actionButton)
        } else {
            mainStack.addArrangedSubview(UIView())
        }
        
        return mainStack
    }
    
    private func createNotificationItem(text: String, time: String, color: UIColor) -> UIView {
        let dotView = UIView()
        dotView.backgroundColor = color
        dotView.layer.cornerRadius = 4
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        dotView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 15)
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .lightGray
        
        let labelStack = UIStackView(arrangedSubviews: [textLabel, timeLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        labelStack.alignment = .leading
        
        let hStack = UIStackView(arrangedSubviews: [dotView, labelStack])
        hStack.spacing = 12
        hStack.alignment = .center
        
        return hStack
    }

    private func createScheduleItem(time: String, title: String, tagText: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        container.layer.cornerRadius = 8
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        timeLabel.textColor = .gray

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        let spacerView = UIView()
        
        let tagLabel = UILabel()
        tagLabel.text = tagText
        tagLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        tagLabel.textColor = .darkGray
        tagLabel.backgroundColor = UIColor(white: 0.9, alpha: 1)
        tagLabel.layer.cornerRadius = 5
        tagLabel.layer.masksToBounds = true
        tagLabel.textAlignment = .center
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [timeLabel, titleLabel, spacerView, tagLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 16
        
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }

    private func createGradeItem(subject: String, score: String, grade: String, isHighlight: Bool = false) -> UIView {
        let subjectLabel = UILabel()
        subjectLabel.text = subject
        subjectLabel.font = .systemFont(ofSize: 16)
        
        let scoreLabel = UILabel()
        scoreLabel.text = score
        scoreLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let gradeLabel = UILabel()
        gradeLabel.text = grade
        gradeLabel.font = .systemFont(ofSize: 14, weight: .bold)
        gradeLabel.textAlignment = .center
        gradeLabel.layer.cornerRadius = 5
        gradeLabel.layer.masksToBounds = true
        
        if isHighlight {
            gradeLabel.backgroundColor = .black
            gradeLabel.textColor = .white
        } else {
            gradeLabel.backgroundColor = UIColor(white: 0.9, alpha: 1)
            gradeLabel.textColor = .darkGray
        }
        
        gradeLabel.translatesAutoresizingMaskIntoConstraints = false
        gradeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

        let stack = UIStackView(arrangedSubviews: [subjectLabel, UIView(), scoreLabel, gradeLabel])
        stack.spacing = 8
        return stack
    }

    private func createNewsItem(university: String, title: String, isNew: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        container.layer.borderColor = UIColor.systemGray5.cgColor
        container.layer.borderWidth = 1
        
        let universityLabel = UILabel()
        universityLabel.text = university
        universityLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        let newTag: UIView? = isNew ? createNewTag() : nil
        
        let headerStack = UIStackView(arrangedSubviews: [universityLabel, newTag, UIView()].compactMap { $0 })
        headerStack.spacing = 8

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray
        
        let detailButton = UIButton(type: .system)
        detailButton.setTitle("자세히 보기", for: .normal)
        detailButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        detailButton.tintColor = .gray
        detailButton.layer.cornerRadius = 15
        detailButton.layer.borderColor = UIColor.systemGray4.cgColor
        detailButton.layer.borderWidth = 1
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        detailButton.widthAnchor.constraint(equalToConstant: 90).isActive = true

        let mainStack = UIStackView(arrangedSubviews: [headerStack, titleLabel, detailButton])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.alignment = .leading
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

    private func createActionButton(iconName: String, title: String) -> UIView {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.layer.borderWidth = 1

        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .label
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        
        let stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(stack)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 80),
            stack.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        return button
    }
    
    private func createNewTag() -> UIView {
        let label = UILabel()
        label.text = "NEW"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .systemRed
        label.textAlignment = .center
        
        let view = UIView()
        view.layer.borderColor = UIColor.systemRed.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6)
        ])
        
        return view
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
}


// MARK: - Reusable CardView

class CardView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
