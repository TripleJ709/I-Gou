//
//  AddUniversityViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/7/25.
//

import UIKit

class AddUniversityViewController: UIViewController {

    private var addUniversityView: AddUniversityView?

    override func loadView() {
        let view = AddUniversityView()
        self.addUniversityView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "관심 대학 추가"
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    @objc private func doneButtonTapped() {
        self.dismiss(animated: true)
    }
}
