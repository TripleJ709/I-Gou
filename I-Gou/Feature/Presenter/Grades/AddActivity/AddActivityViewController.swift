//
//  AddActivityDelegate.swift
//  I-Gou
//
//  Created by 장주진 on 11/10/25.
//

import UIKit

// 이 컨트롤러가 완료되었을 때 ExtraCurricularViewController에게 알려주기 위한 규칙
protocol AddActivityDelegate: AnyObject {
    func didAddActivity(type: String, title: String, hours: Int, date: Date)
}

class AddActivityViewController: UIViewController {

    private var addActivityView: AddActivityView?
    weak var delegate: AddActivityDelegate?

    override func loadView() {
        let view = AddActivityView()
        self.addActivityView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }

    private func setupButtonActions() {
        addActivityView?.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addActivityView?.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let view = self.addActivityView,
              let type = view.typeTextField.text, !type.isEmpty,
              let title = view.titleTextField.text, !title.isEmpty,
              let hoursText = view.hoursTextField.text, let hours = Int(hoursText)
        else {
            print("모든 항목을 올바르게 입력하세요.")
            return
        }
        
        let activityDate = view.activityDatePicker.date
        
        delegate?.didAddActivity(type: type, title: title, hours: hours, date: activityDate)
        self.dismiss(animated: true)
    }
}
