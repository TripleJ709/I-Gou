//
//  AddSchedulViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/1/25.
//

import UIKit

class AddScheduleViewController: UIViewController {

    private var addScheduleView: AddScheduleView?
    weak var delegate: AddScheduleDelegate?

    override func loadView() {
        let view = AddScheduleView()
        self.addScheduleView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtonActions()
    }

    private func setupButtonActions() {
        addScheduleView?.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addScheduleView?.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let title = addScheduleView?.titleTextField.text, !title.isEmpty,
              let date = addScheduleView?.datePicker.date else { return }
        delegate?.didAddSchedule(title: title, date: date)
        
        self.dismiss(animated: true)
    }
}

protocol AddScheduleDelegate: AnyObject {
    func didAddSchedule(title: String, date: Date)
}
