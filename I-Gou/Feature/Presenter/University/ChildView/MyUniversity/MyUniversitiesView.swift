//
//  MyUniversityView.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit

class MyUniversitiesView: UIView {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    weak var delegate: MyUniversitiesViewDelegate?
    
    private let analysisItemStackView = UIStackView()
    
    enum Status: String {
        case challenging = "challenging"
        case appropriate = "appropriate"
        case safe = "safe"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAnalysisCard(with items: [UniversityItem]) {
        // 1. 스택뷰를 비웁니다.
        analysisItemStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 2. 데이터가 없으면 '없음' 라벨을 추가
        if items.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "추가된 대학이 없습니다.\n대학을 추가하고 합격 가능성을 분석해보세요."
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            emptyLabel.font = .systemFont(ofSize: 14)
            analysisItemStackView.addArrangedSubview(emptyLabel)
        } else {
            // 3. 데이터가 있으면 뷰를 생성하여 스택뷰에 추가
            let universityItemViews = items.map { createUniversityItem(data: $0) }
            universityItemViews.forEach { analysisItemStackView.addArrangedSubview($0) }
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
        
        analysisItemStackView.axis = .vertical
        analysisItemStackView.spacing = 16
        
        mainStackView.addArrangedSubview(createAnalysisCard())
        mainStackView.addArrangedSubview(createSuggestionCard())
        
        setupLayout()
    }
    
    // 5. [수정] ⭐️ setupLayout 수정
    private func setupLayout() {
        NSLayoutConstraint.activate([
            // 6. ⭐️ ScrollView: self(MyUniversitiesView)의 전체를 채움
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
    
    private func createAnalysisCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "합격 가능성 분석", subtitle: "현재 성적 기준 예상 합격 가능성")
        
        // 8. [수정] 하드코딩된 뷰 대신, 비어있는 analysisItemStackView를 추가
        let stack = UIStackView(arrangedSubviews: [header, analysisItemStackView]) // 9. [수정]
        
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
    
    private func createSuggestionCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(iconName: "chart.line.uptrend.xyaxis", title: "성적 개선 제안", subtitle: nil)
        
        let suggestion1 = createSuggestionItem(iconName: "info.circle.fill", text: "수학 성적 향상 필요\n목표 대학 합격을 위해 수학 성적을 3점 향상시키세요", color: .systemBlue)
        let suggestion2 = createSuggestionItem(iconName: "book.closed.fill", text: "비교과 활동 보완\n봉사활동 시간을 20시간 더 확보하면 도움이 됩니다", color: .systemGreen)
        
        let stack = UIStackView(arrangedSubviews: [header, suggestion1, suggestion2])
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
    
    private func createCardHeader(iconName: String? = nil, title: String, subtitle: String?) -> UIView {
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
    
    // [수정] createUniversityItem 함수
    private func createUniversityItem(data: UniversityItem) -> UIView {
        let container = UniversityItemView()
        container.universityData = data
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(universityItemTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        
        let uniLabel = UILabel()
        uniLabel.text = data.universityName
        uniLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = .systemYellow
        
        
        let status = Status(rawValue: data.status) ?? .appropriate
        let statusTag = createStatusTag(status: status)
        
        let headerStack = UIStackView(arrangedSubviews: [uniLabel, starIcon, UIView(), statusTag])
        headerStack.spacing = 4
        headerStack.alignment = .center // 이제 에러가 나지 않습니다.
        
        let deptLabel = UILabel()
        deptLabel.text = data.department
        deptLabel.font = .systemFont(ofSize: 14)
        
        let majorLabel = UILabel()
        majorLabel.text = data.major
        majorLabel.font = .systemFont(ofSize: 14)
        majorLabel.textColor = .gray
        
        let detailStack = UIStackView(arrangedSubviews: [deptLabel, majorLabel])
        detailStack.spacing = 4
        
        let myScoreLabel = UILabel()
        myScoreLabel.text = "내 성적: \(data.myScore)"
        myScoreLabel.font = .systemFont(ofSize: 13)
        
        let requiredScoreLabel = UILabel()
        requiredScoreLabel.text = "요구 성적: \(data.requiredScore)"
        requiredScoreLabel.font = .systemFont(ofSize: 13)
        requiredScoreLabel.textAlignment = .right
        
        let scoreLabelStack = UIStackView(arrangedSubviews: [myScoreLabel, requiredScoreLabel])
        
        // 2. [수정] progressView를 사용하기 전에 먼저 선언합니다.
        let progressView = UIProgressView()
        let progress = (data.requiredScore > 0) ? (data.myScore / data.requiredScore) : 0
        progressView.progress = progress
        progressView.progressTintColor = (status == .safe) ? .systemGreen : ((status == .challenging) ? .systemYellow : .systemBlue)
        
        let deadlineLabel = UILabel()
        deadlineLabel.text = "마감일: \(data.deadline)"
        deadlineLabel.font = .systemFont(ofSize: 13)
        deadlineLabel.textColor = .gray
        
        let detailButton = UIButton(type: .system)
        detailButton.setTitle("상세 정보", for: .normal)
        // ... (detailButton 나머지 설정) ...
        
        let footerStack = UIStackView(arrangedSubviews: [deadlineLabel, UIView(), detailButton])
        footerStack.alignment = .center
        
        // 3. [수정] 'progressView'가 위에서 선언되었으므로 이제 에러가 나지 않습니다.
        let mainStack = UIStackView(arrangedSubviews: [headerStack, detailStack, scoreLabelStack, progressView, footerStack])
        mainStack.axis = .vertical // 이제 에러가 나지 않습니다.
        mainStack.spacing = 8
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
    
    private func createStatusTag(status: Status) -> UIView {
        let (text, iconName, color): (String, String, UIColor) = {
            switch status {
            case .challenging: return ("소신", "triangle.fill", .systemYellow)
            case .appropriate: return ("적정", "circle", .systemBlue)
            case .safe: return ("안전", "checkmark", .systemGreen)
            }
        }()
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = color
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = color
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.spacing = 4
        
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.15)
        container.layer.cornerRadius = 8
        container.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
        ])
        
        return container
    }
    
    private func createSuggestionItem(iconName: String, text: String, color: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.1)
        container.layer.cornerRadius = 10
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = color
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.spacing = 12
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    @objc private func universityItemTapped(_ sender: UITapGestureRecognizer) {
        guard let itemView = sender.view as? UniversityItemView,
              let data = itemView.universityData else { return }
        
        delegate?.didSelectUniversity(data)
    }
}

protocol MyUniversitiesViewDelegate: AnyObject {
    func didSelectUniversity(_ university: UniversityItem)
}

class UniversityItemView: UIView {
    var universityData: UniversityItem?
}
