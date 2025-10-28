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
    var scores: [ExamChartData]
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
    @ObservedObject var viewModel: InternalGradesViewModel

    var body: some View {
        Chart(viewModel.performances) { performance in
            ForEach(performance.scores) { score in
                LineMark(
                    x: .value("Date", score.examDate),
                    y: .value("Score", score.score)
                    // [⭐️ 핵심 수정 1 ⭐️] by 파라미터 추가: 과목별로 선을 분리합니다.
                )
                .foregroundStyle(by: .value("Subject", performance.subject)) // [수정] by 사용
                
                PointMark(
                    x: .value("Date", score.examDate),
                    y: .value("Score", score.score)
                    // [⭐️ 핵심 수정 2 ⭐️] by 파라미터 추가: 과목별로 점을 분리합니다.
                )
                .foregroundStyle(by: .value("Subject", performance.subject)) // [수정] by 사용
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self),
                       let examName = viewModel.examName(for: date) {
                        Text(examName)
                            .font(.caption)
                    }
                }
            }
        }
        // [⭐️ 핵심 수정 3 ⭐️] 차트 범례 추가 (자동으로 생성됩니다)
        .chartLegend(position: .bottom, alignment: .center)
        
        .frame(height: 250)
        .overlay { // 로딩 및 빈 상태 표시
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.performances.isEmpty {
                Text("표시할 성적 데이터가 없습니다.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
}// MARK: - Pie Chart View
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
    var subject: String
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

extension InternalGradesViewModel {
    func examName(for date: Date) -> String? {
        // performances 배열을 순회하며 해당 날짜를 가진 score를 찾아 examName 반환
        for performance in performances {
            if let score = performance.scores.first(where: { Calendar.current.isDate($0.examDate, inSameDayAs: date) }) {
                return score.examName
            }
        }
        return nil // 못 찾으면 nil 반환 (레이블 표시 안 함)
    }
}
