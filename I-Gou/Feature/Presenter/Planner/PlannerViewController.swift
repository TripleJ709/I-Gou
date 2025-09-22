//
//  PlannerViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit

class PlannerViewController: UIViewController {

    // MARK: - Properties
    
    private var plannerView: PlannerView?

    // MARK: - Lifecycle
    
    override func loadView() {
        let view = PlannerView()
        self.plannerView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    }
}
