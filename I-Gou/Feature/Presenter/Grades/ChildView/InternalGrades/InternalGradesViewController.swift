//
//  InternalGradesViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class InternalGradesViewController: UIViewController {

    private var internalGradesView: InternalGradesView?

    override func loadView() {
        // 자신의 짝인 InternalGradesView를 생성하여 view로 지정합니다.
        let view = InternalGradesView()
        self.internalGradesView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 이 컨트롤러와 관련된 로직 (데이터 바인딩, 버튼 액션 등)을
        // 앞으로 이곳에 추가하면 됩니다.
    }
}
