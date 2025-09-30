//
//  MyQuestionViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class MyQuestionsViewController: UIViewController {

    private var myQuestionsView: MyQuestionsView?

    override func loadView() {
        let view = MyQuestionsView()
        self.myQuestionsView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
