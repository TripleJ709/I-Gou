//
//  MockExamViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class MockExamViewController: UIViewController {

    private var mockExamView: MockExamView?

    override func loadView() {
        let view = MockExamView()
        self.mockExamView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 모의고사 뷰 컨트롤러의 배경색을 설정 (GradesViewController에서 설정된 기본 배경 위에 올라옴)
        view.backgroundColor = .clear // 부모 뷰의 배경색을 사용하도록 투명하게 설정
    }
}
