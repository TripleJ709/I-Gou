//
//  GradesViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class GradesViewController: UIViewController {

    private var gradesView: GradesView?

    // 자식 뷰 컨트롤러들 선언
    private lazy var internalGradesVC = InternalGradesViewController()
    private lazy var mockExamVC = MockExamViewController()
    private lazy var extraCurricularVC = ExtraCurricularViewController()
    
    // 현재 활성화된 자식 뷰 컨트롤러
    private var activeViewController: UIViewController?

    override func loadView() {
        let view = GradesView()
        self.gradesView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentButtons()
        
        // 초기 화면 설정
        displayChildController(internalGradesVC)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    }

    private func setupSegmentButtons() {
        gradesView?.internalGradesButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
        gradesView?.mockExamButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
        gradesView?.extraCurricularButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
    }

    @objc private func didTapSegmentButton(_ sender: UIButton) {
        guard let gradesView = self.gradesView else { return }
        
        // 모든 버튼 스타일 초기화
        let allButtons = [gradesView.internalGradesButton, gradesView.mockExamButton, gradesView.extraCurricularButton]
        allButtons.forEach {
            $0.backgroundColor = .clear
            $0.setTitleColor(.gray, for: .normal)
        }
        
        // 선택된 버튼 스타일 활성화
        sender.backgroundColor = .white
        sender.setTitleColor(.black, for: .normal)

        // 버튼에 맞는 자식 컨트롤러 표시
        if sender == gradesView.internalGradesButton {
            displayChildController(internalGradesVC)
        } else if sender == gradesView.mockExamButton {
            displayChildController(mockExamVC)
        } else {
            displayChildController(extraCurricularVC)
        }
    }
    
    // 자식 뷰 컨트롤러 전환 로직
    private func displayChildController(_ newChildVC: UIViewController) {
        if activeViewController == newChildVC { return }

        // 기존 자식이 있으면 제거
        if let existingChildVC = activeViewController {
            existingChildVC.willMove(toParent: nil)
            existingChildVC.view.removeFromSuperview()
            existingChildVC.removeFromParent()
        }
        
        guard let containerView = gradesView?.contentContainerView else { return }
        
        // 새로운 자식 추가
        addChild(newChildVC)
        containerView.addSubview(newChildVC.view)
        
        // **[핵심 수정]** Auto Layout을 사용하여 자식 뷰의 크기를 컨테이너에 맞춤
        newChildVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newChildVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newChildVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newChildVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newChildVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        newChildVC.didMove(toParent: self)
        
        // 활성화된 컨트롤러 업데이트
        self.activeViewController = newChildVC
    }
}
