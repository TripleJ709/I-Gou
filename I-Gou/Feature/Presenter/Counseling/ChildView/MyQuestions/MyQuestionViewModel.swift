//
//  MyQuestionViewModel.swift
//  I-Gou
//
//  Created by 장주진 on 11/29/25.
//

import Foundation
import Combine

@MainActor
class MyQuestionsViewModel: ObservableObject {
    
    @Published var questions: [CounselingQuestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 질문 등록 성공 시 이벤트를 보냄 (화면 갱신용)
    let didPostQuestionSuccess = PassthroughSubject<Void, Never>()
    
    private let fetchUseCase: FetchMyQuestionsUseCase
    private let postUseCase: PostQuestionUseCase
    
    init(fetchUseCase: FetchMyQuestionsUseCase, postUseCase: PostQuestionUseCase) {
        self.fetchUseCase = fetchUseCase
        self.postUseCase = postUseCase
    }
    
    // 질문 목록 불러오기
    func fetchQuestions() {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                self.questions = try await fetchUseCase.execute()
            } catch {
                print("질문 목록 로드 실패: \(error)")
                self.errorMessage = "질문 목록을 불러오는데 실패했습니다."
            }
        }
    }
    
    // 질문 등록하기
    func postQuestion(text: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                // 카테고리는 일단 고정값으로 넣거나 UI에서 선택받게 수정 가능
                try await postUseCase.execute(question: text, category: "진학상담")
                
                // 성공 알림 및 목록 새로고침
                self.didPostQuestionSuccess.send()
                await self.fetchQuestions()
            } catch {
                print("질문 등록 실패: \(error)")
                self.errorMessage = "질문 등록에 실패했습니다."
            }
        }
    }
}
