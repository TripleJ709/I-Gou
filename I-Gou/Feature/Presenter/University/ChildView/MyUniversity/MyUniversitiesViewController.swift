//
//  MyUniversitiesViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit

class MyUniversitiesViewController: UIViewController {
    private var myUniversitiesView: MyUniversitiesView?

    override func loadView() {
        let view = MyUniversitiesView()
        self.myUniversitiesView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
