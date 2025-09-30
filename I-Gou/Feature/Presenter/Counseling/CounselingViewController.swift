//
//  CounselingViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class CounselingViewController: UIViewController {

    private var counselingView: CounselingView?
    private var activeViewController: UIViewController?
    
    // 자식 컨트롤러들 선언
    private lazy var myQuestionsVC = MyQuestionsViewController()
    private lazy var notificationsVC = NotificationsViewController()
    private lazy var faqVC = FaqViewController()

    override func loadView() {
        let view = CounselingView()
        self.counselingView = view
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentButtons()
        displayChildController(myQuestionsVC)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
        view.backgroundColor = .systemGroupedBackground
    }

    private func setupSegmentButtons() {
        counselingView?.myQuestionsButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
        counselingView?.notificationsButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
        counselingView?.faqButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
    }

    @objc private func didTapSegmentButton(_ sender: UIButton) {
        guard let counselingView = self.counselingView else { return }
        
        let allButtons = [counselingView.myQuestionsButton, counselingView.notificationsButton, counselingView.faqButton]
        allButtons.forEach {
            $0.backgroundColor = .clear
            $0.setTitleColor(.gray, for: .normal)
        }
        
        sender.backgroundColor = .white
        sender.setTitleColor(.black, for: .normal)

        if sender == counselingView.myQuestionsButton {
            displayChildController(myQuestionsVC)
        } else if sender == counselingView.notificationsButton {
            displayChildController(notificationsVC)
        } else {
            displayChildController(faqVC)
        }
    }
    
    private func displayChildController(_ newChildVC: UIViewController) {
        if activeViewController == newChildVC { return }

        if let existingChildVC = activeViewController {
            existingChildVC.willMove(toParent: nil)
            existingChildVC.view.removeFromSuperview()
            existingChildVC.removeFromParent()
        }
        
        guard let containerView = counselingView?.contentContainerView else { return }
        
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
