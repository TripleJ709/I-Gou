//
//  UniversityNewsDetailViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/30/25.
//

import UIKit

class UniversityNewsDetailViewController: UIViewController {

    // HomeViewController에서 데이터를 전달받을 프로퍼티
    var newsItem: UniversityNews?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
    }

    private func setupUI() {
        guard let newsItem = newsItem else { return }
        
        // UINavigationBar의 타이틀을 대학 이름으로 설정
        self.title = newsItem.universityName
        
        let card = CardView()
        
        let titleLabel = UILabel()
        titleLabel.text = newsItem.title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.numberOfLines = 0 // 여러 줄 표시 가능하도록 설정
        
        let contentLabel = UILabel()
        contentLabel.text = newsItem.content
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0 // 여러 줄 표시 가능하도록 설정
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stackView)
        view.addSubview(card)
        
        // Auto Layout 설정
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
