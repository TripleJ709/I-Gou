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
        addScheduleView?.typeSegmentedControl.addTarget(self, action: #selector(typeChanged), for: .valueChanged)

    }

    private func setupButtonActions() {
        addScheduleView?.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        addScheduleView?.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let view = addScheduleView, let title = view.titleTextField.text, !title.isEmpty else {
            print("제목을 입력하세요.")
            return
        }
        
        // 어떤 종류의 일정을 추가할지 결정
        if view.typeSegmentedControl.selectedSegmentIndex == 0 { // 일일 일정
            let time = view.startTimePicker.date
            delegate?.didAddDailySchedule(title: title, time: time)
        } else { // 마감일
            let date = view.deadlineDatePicker.date
            delegate?.didAddDeadline(title: title, date: date)
        }
        
        self.dismiss(animated: true)
    }
    
    @objc private func typeChanged(_ sender: UISegmentedControl) {
            addScheduleView?.switchForm(to: sender.selectedSegmentIndex)
        }
}

protocol AddScheduleDelegate: AnyObject {
    func didAddDailySchedule(title: String, time: Date)
    func didAddDeadline(title: String, date: Date)
}
