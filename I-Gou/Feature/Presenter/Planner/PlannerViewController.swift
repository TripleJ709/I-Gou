//
//  PlannerViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/21/25.
//

import UIKit
import Combine

class PlannerViewController: UIViewController {

    // MARK: - Properties
    
    private var plannerView: PlannerView?
    private let viewModel = PlannerViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    
    override func loadView() {
        let view = PlannerView()
        self.plannerView = view
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        plannerView?.delegate = self
        bindViewModel()
        viewModel.fetchPlannerData()
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.plannerView?.setLoading(isLoading)
            }.store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                }
            }.store(in: &cancellables)
        
        viewModel.$plannerData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                if let data = data {
                    self?.plannerView?.updateUI(with: data)
                }
            }.store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "I-GoU"
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    }
}

extension PlannerViewController: PlannerViewDelegate {
    func didTapAddScheduleButton() {
        let addScheduleVC = AddScheduleViewController()
        addScheduleVC.delegate = self
        self.present(addScheduleVC, animated: true)
    }
}

extension PlannerViewController: AddScheduleDelegate {
    func didAddSchedule(title: String, date: Date) {
        viewModel.addSchedule(title: title, date: date)
    }
}
