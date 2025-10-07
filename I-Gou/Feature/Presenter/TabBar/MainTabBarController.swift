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
        // 탭바 디자인 설정 (선택사항)
        self.tabBar.tintColor = .systemPurple
        self.tabBar.unselectedItemTintColor = .gray
        
        // 각 탭에 해당하는 뷰 컨트롤러들을 UINavigationController로 감싸서 생성합니다.
        let homeNav = createNavController(
            for: HomeViewController(),
            title: "홈",
            image: UIImage(systemName: "house.fill")!, // 채워진 아이콘으로 변경
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
            image: UIImage(systemName: "graduationcap.fill")!, // 채워진 아이콘으로 변경
            tag: 3
        )
        
        let counselingNav = createNavController(
            for: CounselingViewController(),
            title: "상담",
            image: UIImage(systemName: "person.2.fill")!, // 채워진 아이콘으로 변경
            tag: 4
        )
        
        // 탭바에 뷰 컨트롤러 배열 할당
        self.viewControllers = [homeNav, plannerNav, gradesNav, universityNav, counselingNav]
    }
    
    // [추가] 반복되는 코드를 줄이기 위한 헬퍼(helper) 메서드
    private func createNavController(for rootViewController: UIViewController, title: String, image: UIImage, tag: Int) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.tabBarItem.tag = tag
        // rootViewController의 타이틀도 설정해주면 내비게이션 바에 기본 타이틀이 보입니다.
        rootViewController.navigationItem.title = "I-GoU"
        return navController
    }
}
