//
//  HomeView.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit

protocol HomeViewDelegate: AnyObject {
    func didTapViewAllSchedules()
    func didTapViewAllGrades()
}


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
        // 기존에 스택뷰에 있던 모든 뷰를 제거하여 화면을 초기화합니다.
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 새로운 데이터로 카드들을 생성하여 스택뷰에 추가합니다.
        mainStackView.addArrangedSubview(createWelcomeCard(user: data.user))
        mainStackView.addArrangedSubview(createNotificationCard(notifications: data.notifications))
        mainStackView.addArrangedSubview(createTodayScheduleCard(schedules: data.todaySchedules))
        mainStackView.addArrangedSubview(createRecentGradesCard(grades: data.recentGrades))
    }
    
    // MARK: - Private Setup Methods
    
    private func setupUI() {
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        self.addSubview(loadingIndicator) // 로딩 인디케이터 추가
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
        
        // '전체보기' 버튼에 액션을 연결합니다.
        if let headerStack = header as? UIStackView,
           let actionButton = headerStack.arrangedSubviews.last as? UIButton {
            actionButton.addTarget(self, action: #selector(viewAllSchedulesTapped), for: .touchUpInside)
        }
        
        // 스케줄 데이터로 스케줄 아이템 UI를 만듭니다.
        let scheduleItems = schedules.map { schedule in
            createScheduleItem(time: schedule.startTime, title: schedule.title, tagText: schedule.type)
        }
        
        // 최종적으로 헤더와 아이템들을 합쳐서 스택뷰에 넣습니다.
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
        
        // '상세보기' 버튼에 액션을 연결합니다.
        if let headerStack = header as? UIStackView,
           let actionButton = headerStack.arrangedSubviews.last as? UIButton {
            actionButton.addTarget(self, action: #selector(viewAllGradesTapped), for: .touchUpInside)
        }
        
        // 성적 데이터로 성적 아이템 UI를 만듭니다.
        let gradeItems = grades.map { grade in
            createGradeItem(subject: grade.subjectName, score: "\(grade.score)점", grade: grade.gradeLevel, isHighlight: grade.gradeLevel == "1등급")
        }
        
        // 최종적으로 헤더와 아이템들을 합쳐서 스택뷰에 넣습니다.
        let stackView = UIStackView(arrangedSubviews: [header] + gradeItems)
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
    
    // [추가된 부분] 빠져있던 createGradeItem 함수
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
    
    @objc private func viewAllSchedulesTapped() {
        delegate?.didTapViewAllSchedules()
    }
    
    @objc private func viewAllGradesTapped() {
        delegate?.didTapViewAllGrades()
    }
}
