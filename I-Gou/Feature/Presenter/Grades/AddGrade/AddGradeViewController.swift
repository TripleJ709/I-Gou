//
//  AddGradeViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/6/25.
//

import UIKit

protocol AddGradeDelegate: AnyObject {
    // examType, examName, examDate와 함께 각 과목 정보를 전달
    func didAddGrades(examType: String, examName: String, examDate: Date, grades: [GradeInputData])
}

class AddGradeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GradeInputCellDelegate {

    private var addGradeView: AddGradeView?
    weak var delegate: AddGradeDelegate?
    
    // 테이블 뷰 데이터를 관리할 배열 (초기 1개 행)
    private var gradeInputs: [GradeInputData] = [GradeInputData()]

    override func loadView() {
        let view = AddGradeView()
        self.addGradeView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupButtonActions()
        
        // 키보드 관련 설정 (옵션)
        setupKeyboardDismissal()
    }
    
    private func setupTableView() {
        addGradeView?.tableView.dataSource = self
        addGradeView?.tableView.delegate = self
        addGradeView?.tableView.rowHeight = UITableView.automaticDimension // 내용에 맞게 높이 조절
        addGradeView?.tableView.estimatedRowHeight = 60 // 예상 높이
    }

    private func setupButtonActions() {
        addGradeView?.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addGradeView?.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        addGradeView?.addSubjectButton.addTarget(self, action: #selector(addSubjectButtonTapped), for: .touchUpInside)
    }

    @objc private func cancelButtonTapped() { self.dismiss(animated: true) }

    @objc private func addSubjectButtonTapped() {
        // 데이터 배열에 빈 항목 추가하고 테이블 뷰 갱신
        gradeInputs.append(GradeInputData())
        addGradeView?.tableView.insertRows(at: [IndexPath(row: gradeInputs.count - 1, section: 0)], with: .automatic)
        // 테이블 뷰 높이 재계산 (동적 높이를 위해)
        addGradeView?.tableView.beginUpdates()
        addGradeView?.tableView.endUpdates()
    }

    @objc private func saveButtonTapped() {
        // 시험 정보 유효성 검사
        guard let view = self.addGradeView,
              let examName = view.examNameTextField.text,
            !examName.isEmpty
        else {
            print("시험명과 날짜를 입력하세요.")
            return
        }
        let examDate = view.examDatePicker.date
        
        // 내신/모의고사 구분
        let selectedIndex = view.examTypeSegmentedControl.selectedSegmentIndex
        let examType = (selectedIndex == 0) ? "내신" : "모의고사"

        // 테이블 뷰 데이터 유효성 검사 (모든 과목 정보가 입력되었는지 등)
        let validGrades = gradeInputs.filter { $0.subject != nil && !$0.subject!.isEmpty && $0.score != nil && !$0.score!.isEmpty }
        
        guard !validGrades.isEmpty else {
            print("성적 정보를 하나 이상 올바르게 입력하세요.")
            return
        }
        
        // Delegate를 통해 모든 데이터 전달
        delegate?.didAddGrades(examType: examType, examName: examName, examDate: examDate, grades: validGrades)
        self.dismiss(animated: true)
    }
    
    // 키보드 내리기 설정
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeInputs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GradeInputCell.identifier, for: indexPath) as? GradeInputCell else {
            return UITableViewCell()
        }
        
        let data = gradeInputs[indexPath.row]
        cell.configure(subject: data.subject, score: data.score, gradeLevel: data.gradeLevel)
        cell.delegate = self
        cell.indexPath = indexPath // 셀에게 자신의 인덱스 알려주기
        
        return cell
    }
    
    // MARK: - GradeInputCellDelegate
    // 셀 내부 텍스트필드 값이 변경될 때마다 호출되어 데이터 배열 업데이트
    func didChangeValue(in cell: GradeInputCell, subject: String?, score: String?, gradeLevel: String?) {
        guard let indexPath = cell.indexPath else { return }
        gradeInputs[indexPath.row].subject = subject
        gradeInputs[indexPath.row].score = score
        gradeInputs[indexPath.row].gradeLevel = gradeLevel
    }
}
