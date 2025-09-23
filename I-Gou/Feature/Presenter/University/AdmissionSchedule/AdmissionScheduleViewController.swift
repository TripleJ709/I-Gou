//
//  AdmissionScheduleViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit

class AdmissionsScheduleViewController: UIViewController {

    private var admissionsScheduleView: AdmissionsScheduleView?

    override func loadView() {
        let view = AdmissionsScheduleView()
        self.admissionsScheduleView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
