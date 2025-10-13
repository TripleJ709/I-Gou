//
//  MockExamViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class MockExamViewController: UIViewController {

    private var mockExamView: MockExamView?

    override func loadView() {
        let view = MockExamView()
        self.mockExamView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
