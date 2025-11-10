//
//  InternalGradeViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import Foundation
import Combine
import SwiftUI

class InternalGradesViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI가 구독할 상태)
    @Published var performances: [SubjectPerformance] = [] // 라인 차트용
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var gradeDistribution: [GradeDistribution] = [] // 파이 차트용
    
    // MARK: - Use Cases (비즈니스 로직)
    private let fetchInternalGradesUseCase: FetchInternalGradesUseCase
    private let addGradeUseCase: AddGradeUseCase
    private let fetchGradeDistributionUseCase: FetchGradeDistributionUseCase
    
    // MARK: - Initializer (의존성 주입)
    init(
        fetchInternalGradesUseCase: FetchInternalGradesUseCase,
        addGradeUseCase: AddGradeUseCase,
        fetchGradeDistributionUseCase: FetchGradeDistributionUseCase
    ) {
        self.fetchInternalGradesUseCase = fetchInternalGradesUseCase
        self.addGradeUseCase = addGradeUseCase
        self.fetchGradeDistributionUseCase = fetchGradeDistributionUseCase
    }
    
    // MARK: - Public Methods
    
    // DB에서 성적 데이터를 가져와 라인 차트와 파이 차트 데이터를 모두 업데이트합니다.
    @MainActor
    func fetchGrades() {
        isLoading = true
        errorMessage = nil
        
        Task {
            // 함수가 어떤 경로로든 종료될 때 isLoading을 false로 설정
            defer { isLoading = false }
            
            do {
                // [수정] 1. 두 개의 API를 동시에 비동기적으로 호출
                async let fetchedLineChartData = fetchInternalGradesUseCase.execute()
                async let fetchedPieChartData = fetchGradeDistributionUseCase.execute()
                
                // --- 2. 라인 차트 데이터 가공 ---
                let lineChartData = try await fetchedLineChartData
                print("✅ 서버에서 받은 라인 차트 데이터:", lineChartData)
                
                // ISO 8601 날짜 형식 처리 (T와 Z, 밀리초 포함)
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                // 서버 데이터([SubjectScoreData]) -> 차트 데이터([SubjectPerformance]) 변환
                self.performances = lineChartData.compactMap { subjectData -> SubjectPerformance? in
                    let scores = subjectData.scores.compactMap { scoreData -> ExamChartData? in
                        guard let date = isoFormatter.date(from: scoreData.date) else {
                            print("⚠️ 날짜 변환 실패: \(scoreData.date) for \(subjectData.subject)")
                            return nil
                        }
                        return ExamChartData(examName: scoreData.month, score: scoreData.score, examDate: date)
                    }
                    
                    guard !scores.isEmpty else { return nil }
                    
                    let color = colorForSubject(subjectData.subject)
                    return SubjectPerformance(subject: subjectData.subject, scores: scores, color: color)
                }
                
                // --- 3. 파이 차트 데이터 가공 ---
                let pieChartData = try await fetchedPieChartData
                print("✅ 서버에서 받은 파이 차트 데이터:", pieChartData)
                
                self.gradeDistribution = pieChartData.map { data in
                    return GradeDistribution(
                        grade: data.grade_level,
                        count: data.count,
                        color: colorForGrade(data.grade_level) // 등급별 색상 매핑
                    )
                }
                
                print("📊 라인 차트 데이터:", self.performances)
                print("🥧 파이 차트 데이터:", self.gradeDistribution)
                
            } catch {
                print("❌ 성적 데이터 로딩 실패:", error)
                self.errorMessage = "성적 데이터를 불러오는데 실패했습니다."
            }
        }
    }
    
    // '성적 추가' 화면에서 호출되는 함수
    func addGradeRecord(examType: String, examName: String, subject: String, score: Int, gradeLevel: String?, examDate: Date) {
        isLoading = true // 로딩 시작
        Task {
            do {
                // UseCase를 통해 서버에 데이터 전송 (이 부분은 이전 답변에서 완성함)
                try await addGradeUseCase.execute(
                    examType: examType,
                    examName: examName,
                    subject: subject,
                    score: score,
                    gradeLevel: gradeLevel,
                    examDate: examDate
                )
                
                // 성공 시 데이터 새로고침
                await fetchGrades()
            } catch {
                await MainActor.run {
                    self.errorMessage = "성적 추가에 실패했습니다."
                    self.isLoading = false // 에러 발생 시 로딩 종료
                }
            }
        }
    }
    
    func findScores(at date: Date) -> (String, [(subject: String, score: Int, color: Color)])? {
        
        let allScores = performances.flatMap { $0.scores }
        
        guard let closestScore = allScores.min(by: { abs($0.examDate.timeIntervalSince(date)) < abs($1.examDate.timeIntervalSince(date)) }) else {
            return nil
        }
        
        var scoresAtDate: [(subject: String, score: Int, color: Color)] = []
        let examName = closestScore.examName
        
        for performance in performances {
            if let score = performance.scores.first(where: { $0.examName == examName }) {
                scoresAtDate.append((subject: performance.subject, score: score.score, color: performance.colorForSubject()))
            }
        }
        
        guard !scoresAtDate.isEmpty else { return nil }
        
        return (examName, scoresAtDate.sorted(by: { $0.subject < $1.subject }))
    }
    
    // [⭐️ 추가] X축 레이블을 위한 헬퍼 함수
    func examName(for date: Date) -> String? {
        for performance in performances {
            if let score = performance.scores.first(where: { Calendar.current.isDate($0.examDate, inSameDayAs: date) }) {
                return score.examName
            }
        }
        return nil
    }
    
    // MARK: - Private Helper Methods
    
    // 라인 차트용 과목별 색상 헬퍼
    private func colorForSubject(_ subject: String) -> Color {
        switch subject {
        case "국어": return .orange
        case "수학": return .blue
        case "영어": return .green
            // TODO: 더 많은 과목에 대한 색상 추가 필요
        default: return .gray
        }
    }
    
    // 파이 차트용 등급별 색상 헬퍼
    private func colorForGrade(_ grade: String) -> Color {
        switch grade {
        case "1": return .green
        case "2": return .blue
        case "3": return .orange
        case "4": return .red
            // TODO: 나머지 등급 색상 추가 필요
        default: return .gray
        }
    }
}
