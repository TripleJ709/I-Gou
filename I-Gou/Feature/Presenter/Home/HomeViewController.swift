//
//  HomeViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var homeView: HomeView?
    
    // MARK: - Lifecycle
    override func loadView() {
        let view = HomeView()
        self.homeView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        guard let homeView = self.homeView else { return }
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
        self.view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    }
}
