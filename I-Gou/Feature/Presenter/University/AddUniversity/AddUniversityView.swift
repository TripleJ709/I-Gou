//
//  AddUniversityView.swift
//  I-Gou
//
//  Created by 장주진 on 10/7/25.
//

import UIKit

class AddUniversityView: UIView {

    let searchBar = UISearchBar()
    let resultsStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        searchBar.placeholder = "대학 이름으로 검색"
        searchBar.searchBarStyle = .prominent
        
        resultsStackView.axis = .vertical
        resultsStackView.spacing = 10
        
        // 가짜 검색 결과
        let result1 = createResultButton(title: "서울대학교")
        let result2 = createResultButton(title: "연세대학교")
        let result3 = createResultButton(title: "고려대학교")
        resultsStackView.addArrangedSubview(result1)
        resultsStackView.addArrangedSubview(result2)
        resultsStackView.addArrangedSubview(result3)
        
        let mainStack = UIStackView(arrangedSubviews: [searchBar, resultsStackView, UIView()])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    private func createResultButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 10
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }
}
