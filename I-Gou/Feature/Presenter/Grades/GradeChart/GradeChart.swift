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

// MARK: - Line Chart View
struct GradeLineChartView: View {
    @ObservedObject var viewModel: InternalGradesViewModel
    // @State private var selectedDate: Date? // <-- 터치 기능 삭제

    var body: some View {
        Chart(viewModel.performances) { performance in
            ForEach(performance.scores) { score in
                LineMark(
                    x: .value("Date", score.examDate),
                    y: .value("Score", score.score)
                )
                // [수정] .foregroundStyle(by:)를 LineMark에만 적용
                .foregroundStyle(by: .value("Subject", performance.subject))
                
                PointMark(
                    x: .value("Date", score.examDate),
                    y: .value("Score", score.score)
                )
                // [수정] PointMark는 ViewModel의 color를 사용
                .foregroundStyle(performance.color)
            }
        }
        // [수정] 색상 범위를 수동으로 지정
        .chartForegroundStyleScale(
            domain: viewModel.performances.map { $0.subject },
            range: viewModel.performances.map { $0.colorForSubject() }
        )
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
        .chartLegend(position: .bottom, alignment: .center)
        .frame(height: 250)
        
        // [삭제] .chartOverlay { ... }
        
        .overlay { // 로딩 및 빈 상태 표시
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.performances.isEmpty {
                Text("표시할 성적 데이터가 없습니다.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        
        // [삭제] .annotation(...) { ... }
        // [삭제] .animation(...)
    }
}

// MARK: - Pie Chart View
struct GradePieChartView: View {
    // [수정] @ObservedObject로 ViewModel을 받습니다.
    @ObservedObject var viewModel: InternalGradesViewModel

    var body: some View {
        // [수정] viewModel.gradeDistribution 데이터를 사용합니다.
        Chart(viewModel.gradeDistribution) { data in
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
        // [추가] 데이터가 없을 때 안내 문구 표시
        .overlay {
            if viewModel.gradeDistribution.isEmpty && !viewModel.isLoading {
                Text("등급 분포 데이터가 없습니다.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
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

// MARK: - Mock Exam Bar Chart View
struct MockExamBarChartView: View {
    
    @ObservedObject var viewModel: MockExamViewModel
    
    var body: some View {
        Chart(viewModel.barChartData) { scoreData in
            BarMark(
                x: .value("Month", scoreData.month),
                y: .value("Score", scoreData.score)
            )
            // [⭐️ 핵심 수정 1 ⭐️]
            // 수동으로 색을 칠하는 대신, 'subject'별로 색을 자동 할당하도록 'by:'를 사용합니다.
            // 이것이 범례를 만드는 핵심입니다.
            .foregroundStyle(by: .value("Subject", scoreData.subject))
            .position(by: .value("Subject", scoreData.subject))
        }
        // [⭐️ 핵심 수정 2 ⭐️]
        // 차트가 각 'subject' 이름에 어떤 색을 매핑할지 수동으로 지정해줍니다.
        // (ViewModel의 colorForSubject 헬퍼 로직과 동일하게)
        .chartForegroundStyleScale([
            "국어": Color.orange,
            "수학": Color.blue,
            "영어": Color.green,
            "탐구(1)": Color.purple, // 예시: 다른 과목 색상 추가
            "탐구(2)": Color.pink,
            "한국사": Color.brown
            // TODO: DB에 저장된 모든 과목명에 대해 색상 지정
        ])
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 5))
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        // [⭐️ 핵심 수정 3 ⭐️]
        // 이 줄은 이미 있었지만, .foregroundStyle(by:)와 함께 작동하여 범례를 표시합니다.
        .chartLegend(position: .bottom, alignment: .center)
        .frame(height: 250)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.barChartData.isEmpty {
                Text("모의고사 성적 추이 데이터가 없습니다.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
}
