//
//  MockExamView.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit
import SwiftUI // SwiftUI Charts를 사용하기 위해 필요

class MockExamView: UIView {

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
        // 기본 뷰 설정
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        
        // 뷰 계층 설정 (self에 mainStackView를 바로 추가)
        self.addSubview(mainStackView)
        
        // 메인 스택뷰에 모의고사 관련 컴포넌트 추가
        mainStackView.addArrangedSubview(createMockExamTrendCard())
        mainStackView.addArrangedSubview(createRecentMockExamResultsCard())
        
        // 레이아웃 설정
        setupLayout()
    }

    private func setupLayout() {
        // mainStackView를 self의 경계에 맞게 설정합니다.
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    // MARK: - View Factory Methods
    
    // 모의고사 성적 추이 카드 (막대 그래프)
    private func createMockExamTrendCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "모의고사 성적 추이", subtitle: "전국연합학력평가 결과")
        let barChartView = MockExamBarChartView()
        let chartHostView = addSwiftUIView(barChartView)
        
        let stack = UIStackView(arrangedSubviews: [header, chartHostView])
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
    
    // 최근 모의고사 결과 카드 (상세 리스트)
    private func createRecentMockExamResultsCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "최근 모의고사 결과", subtitle: nil)

        let result1 = createMockExamResultItem(month: "9월", totalScore: "264", korean: "90점", math: "85점", english: "89점")
        let result2 = createMockExamResultItem(month: "11월", totalScore: "270", korean: "92점", math: "87점", english: "91점")
        
        let stack = UIStackView(arrangedSubviews: [header, result1, result2])
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

    // MARK: - Helper Methods
    
    private func addSwiftUIView<V: View>(_ swiftUIView: V) -> UIView {
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        return hostingController.view
    }

    private func createCardHeader(title: String, subtitle: String?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        
        if let subtitle = subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 14)
            subtitleLabel.textColor = .gray
            stack.addArrangedSubview(subtitleLabel)
        }
        return stack
    }
    
    // MockExamView.swift

    private func createMockExamResultItem(month: String, totalScore: String, korean: String, math: String, english: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let monthLabel = UILabel()
        monthLabel.text = "\(month)월 전국연합학력평가"
        monthLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let totalScoreLabel = UILabel()
        totalScoreLabel.text = "총점 \(totalScore)"
        totalScoreLabel.font = .systemFont(ofSize: 14, weight: .bold)
        totalScoreLabel.textColor = .white

        let totalScoreContainer = UIView()
        totalScoreContainer.backgroundColor = .systemGray
        totalScoreContainer.layer.cornerRadius = 8
        totalScoreContainer.clipsToBounds = true
        totalScoreContainer.addSubview(totalScoreLabel)
        
        totalScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalScoreLabel.topAnchor.constraint(equalTo: totalScoreContainer.topAnchor, constant: 4),
            totalScoreLabel.bottomAnchor.constraint(equalTo: totalScoreContainer.bottomAnchor, constant: -4),
            totalScoreLabel.leadingAnchor.constraint(equalTo: totalScoreContainer.leadingAnchor, constant: 8),
            totalScoreLabel.trailingAnchor.constraint(equalTo: totalScoreContainer.trailingAnchor, constant: -8)
        ])
        
        let headerStack = UIStackView(arrangedSubviews: [monthLabel, UIView(), totalScoreContainer])
        headerStack.spacing = 8
        headerStack.alignment = .center
        
        let subjectStack = UIStackView()
        subjectStack.axis = .horizontal
        subjectStack.distribution = .fillEqually
        subjectStack.spacing = 16
        
        subjectStack.addArrangedSubview(createSubjectScoreView(subject: "국어", score: korean))
        subjectStack.addArrangedSubview(createSubjectScoreView(subject: "수학", score: math))
        subjectStack.addArrangedSubview(createSubjectScoreView(subject: "영어", score: english))
        
        let mainStack = UIStackView(arrangedSubviews: [headerStack, subjectStack])
        mainStack.axis = .vertical
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
    private func createSubjectScoreView(subject: String, score: String) -> UIView {
        let subjectLabel = UILabel()
        subjectLabel.text = subject
        subjectLabel.font = .systemFont(ofSize: 14)
        subjectLabel.textColor = .gray
        
        let scoreLabel = UILabel()
        scoreLabel.text = score
        scoreLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let stack = UIStackView(arrangedSubviews: [subjectLabel, scoreLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }
}
