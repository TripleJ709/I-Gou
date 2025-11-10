//
//  MockExamView.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit
import SwiftUI

class MockExamView: UIView {
    
    private var viewModel: MockExamViewModel
    private let mainStackView = UIStackView()
    // [추가] "최근 모의고사 결과"를 동적으로 담을 스택뷰
    private let resultsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(viewModel: MockExamViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupLayout() // setupUI에서 호출하지 않고 분리
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ViewModel에서 데이터가 오면 이 함수를 호출하여 리스트를 업데이트
    func updateResultsList(with data: [MockExamRecentResult]) {
        // 기존 결과 삭제 (헤더는 남겨야 함)
        resultsStackView.arrangedSubviews.dropFirst().forEach { $0.removeFromSuperview() }
        
        // 새 결과 추가
        if data.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "최근 모의고사 결과가 없습니다."
            emptyLabel.font = .systemFont(ofSize: 15)
            emptyLabel.textColor = .gray
            resultsStackView.addArrangedSubview(emptyLabel)
        } else {
            for result in data {
                // 서버에서 받은 데이터로 뷰 생성
                let itemView = createMockExamResultItem(
                    title: result.examName,
                    korean: result.scores["국어"],
                    math: result.scores["수학"],
                    english: result.scores["영어"]
                )
                resultsStackView.addArrangedSubview(itemView)
            }
        }
    }
    
    private func setupUI() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        self.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(createMockExamTrendCard())
        mainStackView.addArrangedSubview(createRecentMockExamResultsCard())
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // 막대 그래프 카드
    private func createMockExamTrendCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "모의고사 성적 추이", subtitle: "전국연합학력평가 결과")
        // [수정] barChartView에 ViewModel 전달
        let barChartView = MockExamBarChartView(viewModel: self.viewModel)
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
    
    // 최근 결과 목록 카드
    private func createRecentMockExamResultsCard() -> CardView {
        let card = CardView()
        let header = createCardHeader(title: "최근 모의고사 결과", subtitle: nil)

        // [수정] resultsStackView에 헤더를 미리 추가
        resultsStackView.addArrangedSubview(header)
        
        card.addSubview(resultsStackView)
        NSLayoutConstraint.activate([
            resultsStackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            resultsStackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            resultsStackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            resultsStackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
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
    
    // [수정] 파라미터를 서버 데이터 모델(옵셔널 Int)에 맞게 변경
    private func createMockExamResultItem(title: String, korean: Int?, math: Int?, english: Int?) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 10
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let (total, totalColor) = calculateTotalScore(korean: korean, math: math, english: english)
        let totalScoreLabel = createTagView(text: "총점 \(total)", color: totalColor)
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), totalScoreLabel])
        
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
    
    // [수정] score 파라미터를 옵셔널 Int로 변경
    private func createSubjectScoreView(subject: String, score: Int?) -> UIView {
        let subjectLabel = UILabel()
        subjectLabel.text = subject
        subjectLabel.font = .systemFont(ofSize: 14)
        subjectLabel.textColor = .gray
        
        let scoreLabel = UILabel()
        scoreLabel.text = score != nil ? "\(score!)점" : "- 점" // nil일 경우 "- 점" 표시
        scoreLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        let stack = UIStackView(arrangedSubviews: [subjectLabel, scoreLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }
    
    private func createTagView(text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = color
        
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
    
    // [수정] 파라미터를 옵셔널 Int로 변경
    private func calculateTotalScore(korean: Int?, math: Int?, english: Int?) -> (String, UIColor) {
        let k = korean ?? 0
        let m = math ?? 0
        let e = english ?? 0
        let total = k + m + e
        
        if total == 0 { return ("-", .gray) }
        
        let color: UIColor = total >= 270 ? .systemGreen : (total >= 240 ? .systemBlue : .systemRed)
        return ("\(total)", color)
    }
}
