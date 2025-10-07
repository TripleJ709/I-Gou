//
//  AddGradeViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/6/25.
//

import UIKit

protocol AddGradeDelegate: AnyObject {
    func didAddGrade(subject: String, score: String)
}

class AddGradeViewController: UIViewController {

    private var addGradeView: AddGradeView?
    weak var delegate: AddGradeDelegate?

    override func loadView() {
        let view = AddGradeView()
        self.addGradeView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }

    private func setupButtonActions() {
        addGradeView?.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addGradeView?.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let subject = addGradeView?.subjectTextField.text, !subject.isEmpty,
              let score = addGradeView?.scoreTextField.text, !score.isEmpty else {
            // 간단한 유효성 검사
            print("과목과 점수를 모두 입력하세요.")
            return
        }
        
        delegate?.didAddGrade(subject: subject, score: score)
        self.dismiss(animated: true)
    }
}
