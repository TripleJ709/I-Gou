//
//  FaqViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class FaqViewController: UIViewController {

    private var faqView: FaqView?

    override func loadView() {
        let view = FaqView()
        self.faqView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
