//
//  NotificationViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class NotificationsViewController: UIViewController {

    private var notificationsView: NotificationsView?

    override func loadView() {
        let view = NotificationsView()
        self.notificationsView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
