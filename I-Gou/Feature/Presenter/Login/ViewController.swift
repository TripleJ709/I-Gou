//
//  ViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/20/25.
//

import UIKit

class ViewController: UIViewController {
    
    let test: UILabel = {
        let lb = UILabel()
        lb.text = "로그인뷰 미구현"
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        
    }

    func setUpLayout() {
        view.addSubview(test)
        NSLayoutConstraint.activate([
            test.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            test.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            test.widthAnchor.constraint(equalToConstant: 100),
            test.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

