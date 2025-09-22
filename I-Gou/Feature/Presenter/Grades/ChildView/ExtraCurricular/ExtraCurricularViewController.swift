//
//  ExtraCurricularViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class ExtraCurricularViewController: UIViewController {

    private var extraCurricularView: ExtraCurricularView?

    override func loadView() {
        let view = ExtraCurricularView()
        self.extraCurricularView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
