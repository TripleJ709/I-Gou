//
//  UniversityViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

//
//  UniversityViewController.swift
//  I-Gou
//
//  Created by Gemini on 2025/09/23.
//

import UIKit

class UniversityViewController: UIViewController {
    
    private var universityView: UniversityView?
    private var activeViewController: UIViewController?
    
    // 자식 컨트롤러들 선언
    private lazy var myUniversitiesVC = MyUniversitiesViewController()
    private lazy var admissionsNewsVC = AdmissionsNewsViewController()
    private lazy var admissionsScheduleVC = AdmissionsScheduleViewController()
    
    override func loadView() {
        let view = UniversityView()
        self.universityView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentButtons()
        displayChildController(myUniversitiesVC)
        setupKeyboardDismissal()
        setupAddButtonAction()
        universityView?.keyboardDismissMode = .onDrag
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupSegmentButtons() {
        universityView?.myUniversityButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
        universityView?.admissionsNewsButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
        universityView?.admissionsScheduleButton.addTarget(self, action: #selector(didTapSegmentButton(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapSegmentButton(_ sender: UIButton) {
        guard let universityView = self.universityView else { return }
        
        let allButtons = [universityView.myUniversityButton, universityView.admissionsNewsButton, universityView.admissionsScheduleButton]
        allButtons.forEach {
            $0.backgroundColor = .clear
            $0.setTitleColor(.gray, for: .normal)
        }
        
        sender.backgroundColor = .white
        sender.setTitleColor(.black, for: .normal)
        
        if sender == universityView.myUniversityButton {
            displayChildController(myUniversitiesVC)
        } else if sender == universityView.admissionsNewsButton {
            displayChildController(admissionsNewsVC)
        } else {
            displayChildController(admissionsScheduleVC)
        }
    }
    
    private func displayChildController(_ newChildVC: UIViewController) {
        if activeViewController == newChildVC { return }
        
        if let existingChildVC = activeViewController {
            existingChildVC.willMove(toParent: nil)
            existingChildVC.view.removeFromSuperview()
            existingChildVC.removeFromParent()
        }
        
        guard let containerView = universityView?.contentContainerView else { return }
        
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
    
    private func setupAddButtonAction() {
        universityView?.addFavoriteButton.addTarget(self, action: #selector(addFavoriteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addFavoriteButtonTapped() {
        let addVC = AddUniversityViewController()
        
        // 모달 화면에도 내비게이션 바를 보여주기 위해 UINavigationController로 감쌉니다.
        let navController = UINavigationController(rootViewController: addVC)
        
        self.present(navController, animated: true)
    }
}
