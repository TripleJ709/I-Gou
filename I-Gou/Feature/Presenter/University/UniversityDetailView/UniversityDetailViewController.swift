//
//  UniversityDetailViewController.swift
//  I-Gou
//
//  Created by 장주진 on 10/7/25.
//

import UIKit

class UniversityDetailViewController: UIViewController {

    var universityData: UniversityItem? // 이전 화면에서 데이터를 전달받을 프로퍼티

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
    }

    private func setupUI() {
        guard let data = universityData else { return }
        
        // 내비게이션 바 타이틀 설정
        self.title = data.universityName
        
        let card = CardView()
        
        let departmentLabel = UILabel()
        departmentLabel.text = "\(data.department) | \(data.major)"
        departmentLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let locationLabel = UILabel()
        locationLabel.text = "위치: \(data.location)"
        locationLabel.font = .systemFont(ofSize: 15)
        
        let competitionLabel = UILabel()
        competitionLabel.text = "작년 경쟁률: \(data.competitionRate)"
        competitionLabel.font = .systemFont(ofSize: 15)
        
        let stackView = UIStackView(arrangedSubviews: [departmentLabel, locationLabel, competitionLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stackView)
        view.addSubview(card)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }
}
