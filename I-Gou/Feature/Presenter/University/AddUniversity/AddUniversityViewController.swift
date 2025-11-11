//
//  AddUniversityViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/7/25.
//

import UIKit
import Combine // 1. [추가] Combine 임포트

class AddUniversityViewController: UIViewController {

    private var addUniversityView: AddUniversityView?
    
    // 2. [추가] ⭐️ 에러의 원인: 이 프로퍼티들이 누락되었습니다.
    private var viewModel: MyUniversitiesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // 3. [추가] 현재 검색 단계 (대학/학과)
    private enum SearchStep {
        case university
        case department(university: UniversitySearchResult)
    }
    private var currentStep: SearchStep = .university
    
    // 4. [추가] ⭐️ 선택된 항목을 저장할 변수
    private var selectedUniversity: UniversitySearchResult?
    private var selectedDepartment: DepartmentSearchResult?

    // 5. [추가] ⭐️ ViewModel을 주입받는 init
    init(viewModel: MyUniversitiesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = AddUniversityView()
        self.addUniversityView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "관심 대학 추가"
        setupNavigationBar()
        
        // 6. [추가] 델리게이트 연결
        addUniversityView?.searchBar.delegate = self
        addUniversityView?.delegate = self // AddUniversityView에 델리게이트 프로토콜 선언 필요
        
        bindViewModel() // 7. [추가] ViewModel 바인딩
    }
     
    private func setupNavigationBar() {
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))
        self.navigationItem.rightBarButtonItem = doneButton
        // 8. [추가] 처음에는 '완료' 버튼 비활성화
        doneButton.isEnabled = false
    }

    // 9. [수정] 이제 'viewModel' 등을 찾을 수 있습니다.
    @objc private func doneButtonTapped() {
        guard let university = selectedUniversity, let department = selectedDepartment else { return }
        
        // 1. ViewModel의 저장 함수 호출
        viewModel.saveMyUniversity(university: university, department: department)
        
        // 2. (옵션) ViewModel의 isLoading을 구독하여 로딩 스피너를 보여줄 수 있습니다.
        // 3. (옵션) ViewModel의 didSaveUniversity 신호를 구독하여
        //    저장이 '성공'했을 때만 dismiss 하도록 변경할 수 있습니다.
        
        // 4. (우선) 저장을 요청하고 바로 모달을 닫습니다.
        self.dismiss(animated: true)
    }
    
    // 10. [추가] ViewModel 바인딩 함수
    private func bindViewModel() {
        // 대학 검색 결과 구독
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                // 대학 검색 단계일 때만 UI 업데이트
                if case .university = self?.currentStep {
                    self?.addUniversityView?.updateResults(universities: results)
                }
            }
            .store(in: &cancellables)
            
        // 학과 검색 결과 구독
        viewModel.$departmentResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                // 학과 검색 단계일 때만 UI 업데이트
                if case .department = self?.currentStep {
                    self?.addUniversityView?.updateResults(departments: results)
                }
            }
            .store(in: &cancellables)
            
        // 로딩 상태 구독 (isLoading을 구독하여 로딩 인디케이터 표시)
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터 표시/숨김
                print("Loading: \(isLoading)")
            }
            .store(in: &cancellables)
            
        // (옵션) 저장이 완료되면 자동으로 dismiss
        viewModel.didSaveUniversity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
}

// 11. [추가] SearchBar 델리게이트
extension AddUniversityViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 텍스트가 변할 때마다 대학 검색 실행
        if case .university = currentStep {
            viewModel.search(query: searchText)
        }
        // TODO: 학과 검색 로직 (로컬 필터링 또는 API 호출)
    }
}

// 12. [추가] View 델리게이트 (AddUniversityViewDelegate 프로토콜 필요)
extension AddUniversityViewController: AddUniversityViewDelegate {
    
    // 대학을 탭했을 때
    func didSelectUniversity(_ university: UniversitySearchResult) {
        self.selectedUniversity = university
        self.currentStep = .department(university: university)
        self.title = university.name // 네비게이션 타이틀 변경
        addUniversityView?.searchBar.placeholder = "학과 이름으로 검색"
        addUniversityView?.searchBar.text = ""
        
        // 학과 검색 실행
        viewModel.fetchDepartments(university: university)
    }
    
    // 학과를 탭했을 때
    func didSelectDepartment(_ department: DepartmentSearchResult) {
        self.selectedDepartment = department
        // 최종 선택 완료. '완료' 버튼 활성화
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        // (선택된 학과에 대한 시각적 피드백, 예: 체크마크)
        addUniversityView?.searchBar.text = department.majorName
    }
}
