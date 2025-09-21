//
//  HomeViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // 네비게이션 바 타이틀 설정
        self.title = "I-GoU"
        
        // 이 부분에 홈 화면의 UI 요소(UILabel, UITableView 등)를 추가하고 AutoLayout을 설정합니다.
        // 예시:
        let welcomeLabel = UILabel()
        welcomeLabel.text = "안녕하세요, OOO! 👋"
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(welcomeLabel)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
}
