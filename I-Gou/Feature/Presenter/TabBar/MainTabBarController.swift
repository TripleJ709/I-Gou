//
//  MainTabBarController.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
    }
    
    private func configureTabBar() {
        // 탭별 뷰 컨트롤러 인스턴스 생성
        let homeVC = HomeViewController()
        let plannerVC = PlannerViewController()
        let scoreVC = GradesViewController()
        let universityVC = ViewController() // 임시
        let consultVC = ViewController()  // 임시
        
        // 각 뷰 컨트롤러를 UINavigationController로 감싸주기
        let homeNavController = UINavigationController(rootViewController: homeVC)
        let plannerNavController = UINavigationController(rootViewController: plannerVC)
        let scoreNavController = UINavigationController(rootViewController: scoreVC)
        let universityNavController = UINavigationController(rootViewController: universityVC)
        let consultNavController = UINavigationController(rootViewController: consultVC)
        
        // 탭바 아이템 설정
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        plannerVC.tabBarItem = UITabBarItem(title: "플래너", image: UIImage(systemName: "calendar"), tag: 1)
        scoreVC.tabBarItem = UITabBarItem(title: "성적", image: UIImage(systemName: "chart.bar"), tag: 2)
        universityVC.tabBarItem = UITabBarItem(title: "대학", image: UIImage(systemName: "graduationcap"), tag: 3)
        consultVC.tabBarItem = UITabBarItem(title: "상담", image: UIImage(systemName: "person.2"), tag: 4)
        
        // 탭바에 뷰 컨트롤러 배열 할당
        self.viewControllers = [
            homeNavController,
            plannerNavController,
            scoreNavController,
            universityNavController,
            consultNavController
        ]
        
        // 탭바 디자인 설정 (선택사항)
        self.tabBar.tintColor = .systemPurple
        self.tabBar.unselectedItemTintColor = .gray
    }
}
