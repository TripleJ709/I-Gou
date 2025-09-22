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
struct GradeLineChartView: View {
    let performances: [SubjectPerformance] = [
        .init(subject: "국어", scores: [.init(month: "국어", score: 90), .init(month: "수학", score: 85), .init(month: "영어", score: 92), .init(month: "한국사", score: 98), .init(month: "물리", score: 88), .init(month: "화학", score: 82)], color: .blue),
        .init(subject: "수학", scores: [.init(month: "국어", score: 88), .init(month: "수학", score: 78), .init(month: "영어", score: 88), .init(month: "한국사", score: 95), .init(month: "물리", score: 85), .init(month: "화학", score: 75)], color: .gray)
    ]

    var body: some View {
        Chart {
            RuleMark(y: .value("Goal", 90)).foregroundStyle(Color.gray).lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))

            ForEach(performances) { performance in
                ForEach(performance.scores) { score in
                    LineMark(
                        x: .value("Subject", score.month),
                        y: .value("Score", score.score)
                    )
                    .foregroundStyle(performance.color)
                    .symbol(by: .value("Subject", performance.subject))
                    
                    PointMark(
                        x: .value("Subject", score.month),
                        y: .value("Score", score.score)
                    )
                    .foregroundStyle(performance.color)
                }
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
