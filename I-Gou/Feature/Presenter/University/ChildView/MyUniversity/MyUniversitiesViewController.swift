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
        // [추가] Delegate를 self로 지정
        view.delegate = self
        self.myUniversitiesView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

extension MyUniversitiesViewController: MyUniversitiesViewDelegate {
    func didSelectUniversity(_ university: UniversityItem) {
        print("\(university.universityName) 선택됨")
        let detailVC = UniversityDetailViewController()
        detailVC.universityData = university
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
