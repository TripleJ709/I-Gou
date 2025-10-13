//
//  PlannerView.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit

class PlannerView: UIView {
    
    weak var delegate: PlannerViewDelegate?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            scrollView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
        }
    }
    
    func updateUI(with data: PlannerData) {
        mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        mainStackView.addArrangedSubview(createHeaderView())
        mainStackView.addArrangedSubview(createCalendarCard())
        mainStackView.addArrangedSubview(createTodayScheduleCard(schedules: data.todaySchedules))
        mainStackView.addArrangedSubview(createDeadlineCard(deadlines: data.deadlines))
        mainStackView.addArrangedSubview(createStudyStatusCard())
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
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
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    @objc private func addScheduleButtonTapped() {
        delegate?.didTapAddScheduleButton()
    }
    
    // MARK: - View Factory Methods
    
    private func createHeaderView() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "학습 플래너"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        dateLabel.text = formatter.string(from: Date())
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 4
        
        let addButton = UIButton(type: .system)
        addButton.setTitle("+ 일정 추가", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        addButton.backgroundColor = .black
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 8
        addButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        addButton.addTarget(self, action: #selector(addScheduleButtonTapped), for: .touchUpInside)
        
        let headerStack = UIStackView(arrangedSubviews: [labelStack, addButton])
        headerStack.alignment = .center
        headerStack.distribution = .equalCentering
        
        return headerStack
    }
    
    private func createCalendarCard() -> UIView {
        let card = CardView()
        let header = createCardHeader(iconName: "calendar", title: "달력")
        
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.calendar = .current
        calendarView.locale = .current
        
        let calendar = Calendar.current
        let today = Date()
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        calendarView.visibleDateComponents = dateComponents
        
        let selection = UICalendarSelectionSingleDate(delegate: nil)
        selection.selectedDate = dateComponents
        calendarView.selectionBehavior = selection
        
        let stack = UIStackView(arrangedSubviews: [header, calendarView])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        return card
    }
    
    private func createTodayScheduleCard(schedules: [DailySchedule]) -> UIView {
        let card = CardView()
        let header = createCardHeader(iconName: "clock", title: "오늘의 일정")
        
        guard !schedules.isEmpty else {
            let emptyLabel = UILabel()
            emptyLabel.text = "오늘의 일정이 없습니다."
            emptyLabel.font = .systemFont(ofSize: 15)
            emptyLabel.textColor = .gray
            
            let stack = UIStackView(arrangedSubviews: [header, emptyLabel])
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
        
        let scheduleItems = schedules.map {
            createScheduleItem(time: $0.time, title: $0.title, subtitle: $0.subtitle, tagText: $0.tag, color: .systemBlue)
        }
        
        let stack = UIStackView(arrangedSubviews: [header] + scheduleItems)
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
    
    private func createDeadlineCard(deadlines: [Deadline]) -> UIView {
        let card = CardView()
        let header = createCardHeader(iconName: "book.pages", title: "다가오는 마감일")
        
        guard !deadlines.isEmpty else {
            let emptyLabel = UILabel()
            emptyLabel.text = "다가오는 마감일이 없습니다."
            emptyLabel.font = .systemFont(ofSize: 15)
            emptyLabel.textColor = .gray
            
            let stack = UIStackView(arrangedSubviews: [header, emptyLabel])
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
        
        let deadlineItems = deadlines.map {
            createDeadlineItem(title: $0.title, date: $0.date, priority: $0.priority, color: .systemRed)
        }
        
        let stack = UIStackView(arrangedSubviews: [header] + deadlineItems)
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
    
    private func createStudyStatusCard() -> UIView {
        let card = CardView()
        let header = createCardHeader(iconName: "chart.pie", title: "이번 주 학습 현황")
        
        let completedView = createStatusItem(value: "32", label: "완료한 일정")
        let timeView = createStatusItem(value: "18", label: "학습 시간")
        
        let itemStack = UIStackView(arrangedSubviews: [completedView, timeView])
        itemStack.distribution = .fillEqually
        itemStack.spacing = 12
        
        let mainStack = UIStackView(arrangedSubviews: [header, itemStack])
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
    
    private func createCardHeader(iconName: String, title: String) -> UIView {
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .label
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.spacing = 8
        stackView.alignment = .center
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return stackView
    }
    
    private func createScheduleItem(time: String, title: String, subtitle: String, tagText: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        container.layer.cornerRadius = 10
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        timeLabel.textColor = .gray
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .darkGray
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        
        let spacer = UIView()
        let tagView = createTagView(text: tagText, color: color)
        
        let mainStack = UIStackView(arrangedSubviews: [timeLabel, labelStack, spacer, tagView])
        mainStack.spacing = 16
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(mainStack)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func createDeadlineItem(title: String, date: String, priority: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        container.layer.cornerRadius = 10
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let dateLabel = UILabel()
        dateLabel.text = date
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .darkGray
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        
        let spacer = UIView()
        let tagView = createTagView(text: priority, color: color)
        
        let mainStack = UIStackView(arrangedSubviews: [labelStack, spacer, tagView])
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
        container.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        container.layer.cornerRadius = 10
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
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
            container.heightAnchor.constraint(equalToConstant: 90),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
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
}


protocol PlannerViewDelegate: AnyObject {
    func didTapAddScheduleButton()
}
