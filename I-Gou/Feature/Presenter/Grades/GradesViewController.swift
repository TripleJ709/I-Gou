//
//  GradesViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/22/25.
//

import UIKit

class GradesViewController: UIViewController {
    
    private var gradesView: GradesView?
    private var activeViewController: UIViewController?
    
    private lazy var internalGradesVC = InternalGradesViewController()
    private lazy var mockExamVC = MockExamViewController()
    private lazy var extraCurricularVC = ExtraCurricularViewController()
    
    override func loadView() {
        let view = GradesView()
        self.gradesView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentButtons()
        gradesView?.delegate = self
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
        
        let allButtons = [gradesView.internalGradesButton, gradesView.mockExamButton, gradesView.extraCurricularButton]
        allButtons.forEach {
            $0.backgroundColor = .clear
            $0.setTitleColor(.gray, for: .normal)
        }
        
        sender.backgroundColor = .white
        sender.setTitleColor(.black, for: .normal)
        
        if sender == gradesView.internalGradesButton {
            displayChildController(internalGradesVC)
        } else if sender == gradesView.mockExamButton {
            displayChildController(mockExamVC)
        } else {
            displayChildController(extraCurricularVC)
        }
    }
    
    private func displayChildController(_ newChildVC: UIViewController) {
        if activeViewController == newChildVC { return }
        if let existingChildVC = activeViewController {
            existingChildVC.willMove(toParent: nil)
            existingChildVC.view.removeFromSuperview()
            existingChildVC.removeFromParent()
        }
        
        guard let containerView = gradesView?.contentContainerView else { return }
        
        addChild(newChildVC)
        containerView.addSubview(newChildVC.view)
        newChildVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newChildVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newChildVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newChildVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newChildVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        newChildVC.didMove(toParent: self)
        
        self.activeViewController = newChildVC
    }
}

extension GradesViewController: GradesViewDelegate {
    func didTapAddGradeButton() {
        let addGradeVC = AddGradeViewController()
        if let targetDelegate = self.activeViewController as? AddGradeDelegate {
                    addGradeVC.delegate = targetDelegate
                    print("✅ AddGradeVC의 Delegate를 \(type(of: targetDelegate))로 설정했습니다.")
                } else {
                    print("⚠️ 현재 활성화된 뷰 컨트롤러가 AddGradeDelegate를 따르지 않습니다.")
                    // 이 경우, InternalGradesViewController가 AddGradeDelegate를 채택했는지 다시 확인해야 합니다.
                }
        self.present(addGradeVC, animated: true)
    }
}
