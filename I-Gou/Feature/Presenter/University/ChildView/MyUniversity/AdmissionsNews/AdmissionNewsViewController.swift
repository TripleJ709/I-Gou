//
//  AdmissionNewsViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit

class AdmissionsNewsViewController: UIViewController {

    private var admissionsNewsView: AdmissionsNewsView?

    override func loadView() {
        let view = AdmissionsNewsView()
        self.admissionsNewsView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
