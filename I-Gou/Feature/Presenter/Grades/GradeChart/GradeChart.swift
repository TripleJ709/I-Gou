//
//  GradeChart.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import SwiftUI
import Charts

// MARK: - Data Models for Charts
struct MonthlyScore: Identifiable {
    var id = UUID()
    var month: String
    var score: Int
}

struct SubjectPerformance: Identifiable {
    var id = UUID()
    var subject: String
    var scores: [MonthlyScore]
    var color: Color
}

struct GradeDistribution: Identifiable {
    var id = UUID()
    var grade: String
    var count: Int
    var color: Color
}

// MARK: - Line Chart View

class ChartDataStore: ObservableObject {
    // @Published: 이 데이터가 변경되면 SwiftUI 뷰가 자동으로 업데이트됩니다.
    @Published var performances: [SubjectPerformance]
    
    init() {
        // 초기 데이터 설정
        self.performances = [
            .init(subject: "국어", scores: [.init(month: "1학기 중간", score: 90), .init(month: "1학기 기말", score: 85)], color: .orange),
            .init(subject: "수학", scores: [.init(month: "1학기 중간", score: 88), .init(month: "1학기 기말", score: 78)], color: .blue),
            .init(subject: "영어", scores: [.init(month: "1학기 중간", score: 92), .init(month: "1학기 기말", score: 88)], color: .green)
        ]
    }
    
    // 새로운 성적 기록을 데이터에 추가하는 함수
    func addGradeRecord(_ record: InternalGradeRecord) {
        let newMonth = record.examName
        
        // 국어 점수 추가
        if let index = performances.firstIndex(where: { $0.subject == "국어" }) {
            performances[index].scores.append(.init(month: newMonth, score: record.koreanScore))
        }
        // 수학 점수 추가
        if let index = performances.firstIndex(where: { $0.subject == "수학" }) {
            performances[index].scores.append(.init(month: newMonth, score: record.mathScore))
        }
        // 영어 점수 추가
        if let index = performances.firstIndex(where: { $0.subject == "영어" }) {
            performances[index].scores.append(.init(month: newMonth, score: record.englishScore))
        }
    }
}

struct GradeLineChartView: View {
    @ObservedObject var dataStore: ChartDataStore

    var body: some View {
        Chart(dataStore.performances) { performance in
            ForEach(performance.scores) { score in
                LineMark(
                    x: .value("Exam", score.month),
                    y: .value("Score", score.score)
                )
                .foregroundStyle(by: .value("Subject", performance.subject))
                
                PointMark(
                    x: .value("Exam", score.month),
                    y: .value("Score", score.score)
                )
                .foregroundStyle(by: .value("Subject", performance.subject))
            }
        }
        .chartForegroundStyleScale([
            "국어": Color.orange, "수학": Color.blue, "영어": Color.green
        ])
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5))
        }
        .frame(height: 250)
    }
}

// MARK: - Pie Chart View
struct GradePieChartView: View {
    let distribution: [GradeDistribution] = [
        .init(grade: "1등급", count: 2, color: .green),
        .init(grade: "2등급", count: 3, color: .blue),
        .init(grade: "3등급", count: 1, color: .orange)
    ]
    
    var body: some View {
        Chart(distribution) { data in
            SectorMark(
                angle: .value("Count", data.count),
                angularInset: 2.0
            )
            .foregroundStyle(data.color)
            .annotation(position: .overlay) {
                Text("\(data.grade): \(data.count)과목")
                    .font(.caption)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .frame(height: 250)
    }
}

// MARK: - Mock Exam Bar Chart View
struct MockExamScore: Identifiable {
    var id = UUID()
    var month: String
    var subject: String // 국, 수, 영
    var score: Int
    var color: Color
}

struct MockExamBarChartView: View {
    let mockExamScores: [MockExamScore] = [
        .init(month: "3월", subject: "국어", score: 85, color: .orange),
        .init(month: "3월", subject: "수학", score: 78, color: .blue),
        .init(month: "3월", subject: "영어", score: 90, color: .green),
        
        .init(month: "6월", subject: "국어", score: 88, color: .orange),
        .init(month: "6월", subject: "수학", score: 78, color: .blue),
        .init(month: "6월", subject: "영어", score: 88, color: .green),
        
        .init(month: "9월", subject: "국어", score: 90, color: .orange),
        .init(month: "9월", subject: "수학", score: 80, color: .blue),
        .init(month: "9월", subject: "영어", score: 90, color: .green),
        
        .init(month: "11월", subject: "국어", score: 92, color: .orange),
        .init(month: "11월", subject: "수학", score: 82, color: .blue),
        .init(month: "11월", subject: "영어", score: 93, color: .green),
    ]

    var body: some View {
        Chart {
            ForEach(mockExamScores) { scoreData in
                BarMark(
                    x: .value("Month", scoreData.month),
                    y: .value("Score", scoreData.score)
                )
                .foregroundStyle(scoreData.color)
                // 그룹화할 때 subject를 사용합니다.
                .position(by: .value("Subject", scoreData.subject))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5))
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 250)
    }
}
