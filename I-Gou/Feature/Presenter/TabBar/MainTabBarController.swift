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
        self.tabBar.tintColor = .systemPurple
        self.tabBar.unselectedItemTintColor = .gray
    
        let homeNav = createNavController(
            for: HomeViewController(),
            title: "홈",
            image: UIImage(systemName: "house.fill")!,
            tag: 0
        )
        
        let plannerNav = createNavController(
            for: PlannerViewController(),
            title: "플래너",
            image: UIImage(systemName: "calendar")!,
            tag: 1
        )
        
        let gradesNav = createNavController(
            for: GradesViewController(),
            title: "성적",
            image: UIImage(systemName: "chart.bar.xaxis")!,
            tag: 2
        )
        
        let universityNav = createNavController(
            for: UniversityViewController(),
            title: "대학",
            image: UIImage(systemName: "graduationcap.fill")!,
            tag: 3
        )
        
        let counselingNav = createNavController(
            for: CounselingViewController(),
            title: "상담",
            image: UIImage(systemName: "person.2.fill")!,
            tag: 4
        )
        
        self.viewControllers = [homeNav, plannerNav, gradesNav, universityNav, counselingNav]
    }
    
    private func createNavController(for rootViewController: UIViewController, title: String, image: UIImage, tag: Int) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.tabBarItem.tag = tag
        rootViewController.navigationItem.title = "I-GoU"
        return navController
    }
}
