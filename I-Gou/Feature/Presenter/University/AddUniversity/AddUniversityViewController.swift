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
    private var viewModel: MyUniversitiesViewModel
    private var cancellables = Set<AnyCancellable>()
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
            
            // 델리게이트 연결
            addUniversityView?.searchBar.delegate = self
            // 테이블뷰 델리게이트/데이터소스 연결
            addUniversityView?.tableView.delegate = self
            addUniversityView?.tableView.dataSource = self
            
            bindViewModel()
            
            // 화면 진입 시 서치바에 포커스
            addUniversityView?.searchBar.becomeFirstResponder()
        }
     
    private func setupNavigationBar() {
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))
        self.navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
    }

    @objc private func doneButtonTapped() {
        guard let university = selectedUniversity, let department = selectedDepartment else { return }
        viewModel.saveMyUniversity(university: university, department: department)
    }
    
    private func bindViewModel() {
        viewModel.$searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if case .university = self?.currentStep {
                    self?.addUniversityView?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$departmentResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if case .department = self?.currentStep {
                    self?.addUniversityView?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        viewModel.didSaveUniversity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
}

extension AddUniversityViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // [추가] 1번 로그: 서치바 입력이 인식되는지 확인
        print("1️⃣ [iOS] 서치바 입력 감지: \(searchText)")
        
        if case .university = currentStep {
            viewModel.search(query: searchText)
        }
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

extension AddUniversityViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentStep {
        case .university:
            return viewModel.searchResults.count
        case .department:
            return viewModel.departmentResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch currentStep {
        case .university:
            let university = viewModel.searchResults[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = university.name
            content.secondaryText = university.location
            cell.contentConfiguration = content
        case .department:
            let department = viewModel.departmentResults[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = department.majorName
            cell.contentConfiguration = content
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch currentStep {
        case .university:
            let university = viewModel.searchResults[indexPath.row]
            self.selectedUniversity = university
            self.currentStep = .department(university: university)
            
            // UI 업데이트
            self.title = university.name
            addUniversityView?.searchBar.text = ""
            addUniversityView?.searchBar.placeholder = "\(university.name)의 학과를 검색하세요"
            
            // 학과 목록 가져오기
            viewModel.fetchDepartments(university: university)
            
            // 키보드 내리기
            addUniversityView?.searchBar.resignFirstResponder()
            
        case .department:
            let department = viewModel.departmentResults[indexPath.row]
            self.selectedDepartment = department
            
            // UI 업데이트
            addUniversityView?.searchBar.text = department.majorName
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            addUniversityView?.searchBar.resignFirstResponder()
        }
    }
}
