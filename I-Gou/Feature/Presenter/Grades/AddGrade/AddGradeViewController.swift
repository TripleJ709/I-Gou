//
//  AddGradeViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/6/25.
//

import UIKit

protocol AddGradeDelegate: AnyObject {
    func didAddGrade(record: InternalGradeRecord)
}

class AddGradeViewController: UIViewController {
    
    private var addInternalGradeView: AddGradeView?
    weak var delegate: AddGradeDelegate?
    
    override func loadView() {
        let view = AddGradeView()
        self.addInternalGradeView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }
    
    private func setupButtonActions() {
        addInternalGradeView?.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addInternalGradeView?.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let view = self.addInternalGradeView,
              let examName = view.examNameTextField.text, !examName.isEmpty,
              let koreanScoreText = view.koreanScoreTextField.text, let koreanScore = Int(koreanScoreText),
              let mathScoreText = view.mathScoreTextField.text, let mathScore = Int(mathScoreText),
              let englishScoreText = view.englishScoreTextField.text, let englishScore = Int(englishScoreText)
        else {
            print("모든 항목을 올바르게 입력하세요.")
            return
        }
        
        let newRecord = InternalGradeRecord(
            examName: examName,
            koreanScore: koreanScore,
            mathScore: mathScore,
            englishScore: englishScore
        )
        
        delegate?.didAddGrade(record: newRecord)
        self.dismiss(animated: true)
    }
}
