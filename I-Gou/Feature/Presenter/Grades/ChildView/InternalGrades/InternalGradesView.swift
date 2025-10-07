//
//  InternalGradesView.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit
import SwiftUI

class InternalGradesView: UIView {
    
    private var chartDataStore: ChartDataStore
    
    // MARK: - UI Components
    private let mainStackView = UIStackView()
    
    // MARK: - Initializer
    init(chartDataStore: ChartDataStore) {
        self.chartDataStore = chartDataStore
        super.init(frame: .zero)
        setupUI()
        setupLayout()
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
        
        // 메인 스택뷰에 내신 성적 관련 컴포넌트만 추가
        mainStackView.addArrangedSubview(createLineChartCard())
        mainStackView.addArrangedSubview(createDetailedGradesCard())
        mainStackView.addArrangedSubview(createPieChartCard())
        
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
    
    // MARK: - View Factory Methods (From GradesView)
    // 이 아래 부분은 이전 코드와 동일합니다.
    
    private func createLineChartCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "과목별 성적 현황", subtitle: "최근 3학기 성적 변화")
        let lineChartView = GradeLineChartView(dataStore: self.chartDataStore)
        let chartHostView = addSwiftUIView(lineChartView)
        
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
    
    private func createDetailedGradesCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "과목별 상세 성적", subtitle: nil)
        
        let grade1 = createGradeItem(subject: "국어", score: "88", grade: "2등급", goal: "92", trend: .down)
        let grade2 = createGradeItem(subject: "수학", score: "85", grade: "2등급", goal: "90", trend: .up)
        let grade3 = createGradeItem(subject: "영어", score: "89", grade: "2등급", goal: "93", trend: .up)
        let grade4 = createGradeItem(subject: "한국사", score: "96", grade: "1등급", goal: "98", trend: .up)
        
        let stack = UIStackView(arrangedSubviews: [header, grade1, grade2, grade3, grade4])
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
    
    private func createPieChartCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "등급 분포", subtitle: nil)
        let pieChartView = GradePieChartView()
        let chartHostView = addSwiftUIView(pieChartView)
        
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
    
    enum Trend { case up, down }
    private func createGradeItem(subject: String, score: String, grade: String, goal: String, trend: Trend) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let subjectLabel = UILabel()
        subjectLabel.text = subject
        subjectLabel.font = .systemFont(ofSize: 16)
        
        let scoreLabel = UILabel()
        scoreLabel.text = score
        scoreLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        let gradeLabel = UILabel()
        gradeLabel.text = grade
        gradeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        gradeLabel.textColor = .white
        gradeLabel.backgroundColor = (grade == "1등급") ? .systemBlue : .systemGray
        gradeLabel.textAlignment = .center
        gradeLabel.layer.cornerRadius = 8
        gradeLabel.layer.masksToBounds = true
        gradeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let iconName = (trend == .up) ? "arrow.up.right" : "arrow.down.right"
        let iconColor: UIColor = (trend == .up) ? .green : .red
        let trendIcon = UIImageView(image: UIImage(systemName: iconName))
        trendIcon.tintColor = iconColor
        
        let goalLabel = UILabel()
        goalLabel.text = "목표: \(goal)"
        goalLabel.font = .systemFont(ofSize: 14)
        goalLabel.textColor = .gray
        
        let goalStack = UIStackView(arrangedSubviews: [trendIcon, goalLabel])
        goalStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [subjectLabel, UIView(), scoreLabel, gradeLabel, goalStack])
        mainStack.spacing = 8
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
}
