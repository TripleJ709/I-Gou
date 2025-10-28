//
//  InternalGradeViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import Combine
import SwiftUI

class InternalGradesViewModel: ObservableObject {
    @Published var performances: [SubjectPerformance] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let fetchInternalGradesUseCase: FetchInternalGradesUseCase
    private let addGradeUseCase: AddGradeUseCase
    
    init(
        fetchInternalGradesUseCase: FetchInternalGradesUseCase,
        addGradeUseCase: AddGradeUseCase
    ) {
        self.fetchInternalGradesUseCase = fetchInternalGradesUseCase
        self.addGradeUseCase = addGradeUseCase
    }
    
    @MainActor // UI 관련 프로퍼티를 직접 업데이트하므로 @MainActor 지정
    func fetchGrades() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false } // 함수 종료 시 항상 isLoading = false 되도록 보장
            
            do {
                let fetchedData = try await fetchInternalGradesUseCase.execute()
                print("✅ 서버에서 받은 데이터:", fetchedData)
                
                // ISO 8601 날짜 형식 처리
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                // 서버 데이터([SubjectScoreData]) -> 차트 데이터([SubjectPerformance]) 변환
                // compactMap을 사용하여 날짜 변환 실패 시 해당 점수/과목 데이터를 안전하게 제외
                self.performances = fetchedData.compactMap { subjectData -> SubjectPerformance? in
                    let scores = subjectData.scores.compactMap { scoreData -> ExamChartData? in
                        guard let date = isoFormatter.date(from: scoreData.date) else {
                            print("⚠️ 날짜 변환 실패: \(scoreData.date) for \(subjectData.subject)")
                            return nil
                        }
                        return ExamChartData(examName: scoreData.month, score: scoreData.score, examDate: date)
                    }
                    
                    // 유효한 점수가 하나도 없으면 해당 과목은 차트에서 제외
                    guard !scores.isEmpty else { return nil }
                    
                    let color = colorForSubject(subjectData.subject)
                    return SubjectPerformance(subject: subjectData.subject, scores: scores, color: color)
                }
                
                print("📊 차트에 사용할 변환된 데이터:", self.performances)
                
            } catch {
                print("❌ 성적 데이터 로딩 실패:", error)
                self.errorMessage = "성적 데이터를 불러오는데 실패했습니다."
            }
        }
    }
    
    // 과목 이름에 따라 색상을 반환하는 헬퍼 함수
    private func colorForSubject(_ subject: String) -> Color {
        switch subject {
        case "국어": return .orange
        case "수학": return .blue
        case "영어": return .green
            // TODO: 더 많은 과목에 대한 색상 추가 필요
        default: return .gray
        }
    }
    
    // [삭제] colorFromString 함수는 colorForSubject로 통일되었으므로 삭제
    
    // 성적 추가 함수
    func addGradeRecord(
        examType: String,
        examName: String, // InternalGradeRecord 대신 examName 직접 받음
        subject: String,  // 개별 과목 정보 받음
        score: Int,       // 개별 과목 정보 받음
        gradeLevel: String?,// 개별 과목 정보 받음
        examDate: Date
    ) {
        // isLoading = true // 필요 시 로딩 시작
        Task {
            do {
                // UseCase를 호출할 때도 개별 파라미터를 사용해야 합니다.
                // UseCase execute 함수는 InternalGradeRecord를 받으므로,
                // UseCase 자체를 수정하거나 ViewModel에서 임시 객체를 만들어야 합니다.
                // 여기서는 UseCase가 이미 수정되었다고 가정하고 진행합니다.
                
                // --- UseCase가 InternalGradeRecord를 받는 경우 (임시 해결) ---
                let tempRecord = InternalGradeRecord(examName: examName, koreanScore: 0, mathScore: 0, englishScore: 0) // 임시 객체 생성
                // 실제로는 UseCase/Repository/APIService가 개별 파라미터를 받도록 수정하는 것이 더 좋습니다.
                
                // --- UseCase가 개별 파라미터를 받는 이상적인 경우 ---
                try await addGradeUseCase.execute(examType: examType, examName: examName, subject: subject, score: score, gradeLevel: gradeLevel, examDate: examDate)
                
                // 성공 시 데이터 새로고침
                await fetchGrades()
            } catch {
                await MainActor.run {
                    self.errorMessage = "성적 추가에 실패했습니다."
                    // isLoading = false // 필요 시 로딩 해제
                }
            }
        }
    }
}
