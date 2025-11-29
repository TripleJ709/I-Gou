//
//  NotificationViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit
import Combine

class NotificationsViewController: UIViewController {

    private var notificationsView: NotificationsView?
    
    // ⭐️ Clean Architecture 적용
    private var viewModel: NotificationsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // ⭐️ 생성자 주입 (없으면 기본값으로 생성)
    init(viewModel: NotificationsViewModel? = nil) {
        if let vm = viewModel {
            self.viewModel = vm
        } else {
            // 편의상 기본값 생성 (실제로는 CounselingVC에서 주입해주는 게 베스트)
            let api = APIService()
            let repo = DefaultNotificationRepository(apiService: api)
            self.viewModel = NotificationsViewModel(repository: repo)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NotificationsView()
        self.notificationsView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        bindViewModel()
        viewModel.fetchNotifications() // 데이터 로드 시작
    }
    
    // 화면이 다시 나타날 때마다 갱신 (선택사항)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchNotifications()
    }
    
    private func bindViewModel() {
        // 알림 목록 구독
        viewModel.$notifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                print("👀 뷰컨트롤러가 받은 알림 개수: \(items.count)")
                print("알림 내용: \(items)")
                self?.notificationsView?.updateNotifications(items: items)
            }
            .store(in: &cancellables)
    }
}
