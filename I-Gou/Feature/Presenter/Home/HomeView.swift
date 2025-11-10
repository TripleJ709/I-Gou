//
//  HomeView.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit

class HomeView: UIView {
    
    weak var delegate: HomeViewDelegate?
    
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
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods (ViewController가 호출하는 함수들)
    
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            mainStackView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            mainStackView.isHidden = false
        }
    }
    
    func updateUI(with data: HomeData) {
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        mainStackView.addArrangedSubview(createWelcomeCard(user: data.user))
        mainStackView.addArrangedSubview(createNotificationCard(notifications: data.notifications))
        mainStackView.addArrangedSubview(createTodayScheduleCard(schedules: data.todaySchedules))
        mainStackView.addArrangedSubview(createRecentGradesCard(grades: data.recentGrades))
        mainStackView.addArrangedSubview(createUniversityNewsCard(newsItems: data.universityNews))
        mainStackView.addArrangedSubview(createQuickActionsCard())
    }
    
    // MARK: - Private Setup Methods
    
    private func setupUI() {
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        self.addSubview(loadingIndicator)
    }
    
    private func setupLayout() {
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
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    // MARK: - Card Factory Methods (데이터를 파라미터로 받음)
    
    private func createWelcomeCard(user: User) -> UIView {
        let card = CardView()
        
        let greetingLabel = UILabel()
        greetingLabel.text = "안녕하세요, \(user.name)! 👋"
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
    
    private func createNotificationCard(notifications: [Notification]) -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "bell.fill", title: "알림")
        let notificationItems = notifications.map { notification in
            createNotificationItem(text: notification.content, time: notification.createdAt, color: .systemBlue)
        }
        
        let stackView = UIStackView(arrangedSubviews: [header] + notificationItems)
        
        stackView.axis = NSLayoutConstraint.Axis.vertical
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
    
    private func createTodayScheduleCard(schedules: [Schedule]) -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "calendar", title: "오늘의 일정", actionButtonTitle: "전체보기")
        
        if let headerStack = header as? UIStackView,
           let actionButton = headerStack.arrangedSubviews.last as? UIButton {
            actionButton.addTarget(self, action: #selector(viewAllSchedulesTapped), for: .touchUpInside)
        }
        
        let scheduleItems = schedules.map { schedule in
            createScheduleItem(time: schedule.startTime, title: schedule.title, tagText: schedule.type)
        }
        
        let stackView = UIStackView(arrangedSubviews: [header] + scheduleItems)
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
    
    private func createRecentGradesCard(grades: [Grade]) -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "chart.bar.fill", title: "최근 성적", actionButtonTitle: "상세보기")
        
        // '상세보기' 버튼에 액션 연결
        if let headerStack = header as? UIStackView,
           let actionButton = headerStack.arrangedSubviews.last as? UIButton {
            actionButton.addTarget(self, action: #selector(viewAllGradesTapped), for: .touchUpInside)
        }
        
        // 서버에서 받은 'Grade' 데이터 배열을 'gradeItem' 뷰 배열로 변환
        let gradeItems = grades.map { grade in
            // [⭐️ 핵심 수정 1 ⭐️]
            // grade.gradeLevel이 nil일 경우, nil-coalescing operator(??)를 사용해
            // 기본값으로 "-" (하이픈)을 사용하도록 합니다.
            createGradeItem(
                subject: grade.subjectName,
                score: "\(grade.score)점",
                grade: grade.gradeLevel ?? "-", // nil이면 "-" 표시
                isHighlight: grade.gradeLevel == "1등급" // nil과 "1등급"을 비교하면 false가 되므로 안전합니다.
            )
        }
        
        let stackView = UIStackView(arrangedSubviews: [header] + gradeItems)
        
        // [⭐️ 핵심 수정 2 ⭐️]
        // 컴파일러가 .vertical의 타입을 추론하지 못하는 문제를 해결하기 위해
        // NSLayoutConstraint.Axis.vertical 이라고 전체 경로를 적어줍니다.
        stackView.axis = NSLayoutConstraint.Axis.vertical
        
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
    
    // MARK: - UI Element Helper Methods

    private func createHeaderView(iconName: String, title: String, actionButtonTitle: String? = nil) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)

        var titleStackContent: [UIView] = []
        
        if !iconName.isEmpty {
            let iconImageView = UIImageView(image: UIImage(systemName: iconName))
            iconImageView.tintColor = .label
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: 22),
                iconImageView.heightAnchor.constraint(equalToConstant: 22)
            ])
            titleStackContent.append(iconImageView)
        }
        
        titleStackContent.append(titleLabel)
        
        let titleStack = UIStackView(arrangedSubviews: titleStackContent)
        titleStack.spacing = 8
        titleStack.alignment = .center
        
        let mainStack = UIStackView()
        mainStack.addArrangedSubview(titleStack)
        
        if let actionTitle = actionButtonTitle {
            let actionButton = UIButton(type: .system)
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.titleLabel?.font = .systemFont(ofSize: 14)
            actionButton.tintColor = .gray
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
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
    
    private func createUniversityNewsCard(newsItems: [UniversityNews]) -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "star.fill", title: "관심 대학 소식")
        
        let newsItemViews = newsItems.map { createNewsItem(news: $0) }
        
        let itemStack = UIStackView(arrangedSubviews: newsItemViews)
        itemStack.axis = .vertical
        itemStack.spacing = 12
        
        let stackView = UIStackView(arrangedSubviews: [header, itemStack])
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
    
    private func createQuickActionsCard() -> UIView {
        let card = CardView()
        let header = createHeaderView(iconName: "", title: "빠른 기능")
        
        let studyButton = createActionButton(iconName: "book.fill", title: "학습 기록")
        let gradeButton = createActionButton(iconName: "chart.bar.fill", title: "성적 입력")
        
        studyButton.addTarget(self, action: #selector(addScheduleButtonTapped), for: .touchUpInside)
        gradeButton.addTarget(self, action: #selector(addGradeButtonTapped), for: .touchUpInside)
        
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
    
    private func createNewsItem(news: UniversityNews) -> UIView {
        let container = NewsItemView()
        container.newsItem = news
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 10
        container.layer.borderColor = UIColor.systemGray5.cgColor
        container.layer.borderWidth = 1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newsItemTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        
        let universityLabel = UILabel()
        universityLabel.text = news.universityName
        universityLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        let newTag: UIView? = news.isNew ? createNewTag() : nil
        
        let headerStack = UIStackView(arrangedSubviews: [universityLabel, newTag, UIView()].compactMap { $0 })
        headerStack.spacing = 8
        
        let titleLabel = UILabel()
        titleLabel.text = news.title
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray
        titleLabel.numberOfLines = 0
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, titleLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.alignment = .leading
        mainStack.isUserInteractionEnabled = false
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
    
    private func createActionButton(iconName: String, title: String) -> UIButton {
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
    
    @objc private func viewAllSchedulesTapped() {
        delegate?.didTapViewAllSchedules()
    }
    
    @objc private func viewAllGradesTapped() {
        delegate?.didTapViewAllGrades()
    }
    
    @objc private func newsItemTapped(_ sender: UITapGestureRecognizer) {
        guard let newsView = sender.view as? NewsItemView,
              let newsItem = newsView.newsItem else { return }
        delegate?.didSelectUniversityNews(newsItem)
    }
    
    @objc private func addScheduleButtonTapped() {
        delegate?.didTapAddScheduleQuickAction()
    }
    
    @objc private func addGradeButtonTapped() {
        delegate?.didTapAddGradeQuickAction()
    }
}

protocol HomeViewDelegate: AnyObject {
    func didTapViewAllSchedules()
    func didTapViewAllGrades()
    func didSelectUniversityNews(_ newsItem: UniversityNews)
    func didTapAddScheduleQuickAction() 
    func didTapAddGradeQuickAction()
}

class NewsItemView: UIView {
    var newsItem: UniversityNews?
}
