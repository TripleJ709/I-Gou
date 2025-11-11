//
//  AdmissionNewsViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit
import Combine
import SafariServices // 1. [추가] 인앱 브라우저

class AdmissionsNewsViewController: UIViewController {
    
    // 2. [추가] ViewModel, 구독 저장소, 테이블뷰
    private var viewModel: AdmissionsNewsViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tableView = UITableView()
    
    // 3. [추가] ViewModel 주입받는 init
    init(viewModel: AdmissionsNewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupTableView() // 4. [추가] 테이블뷰 설정
        bindViewModel()  // 5. [추가] 뷰모델 바인딩
        
        // 6. [추가] 뷰가 로드되면 뉴스 가져오기
        viewModel.fetchNews()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewsCell.self, forCellReuseIdentifier: "NewsCell") // 7. (NewsCell은 따로 만들어야 함)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        // 8. 뉴스 목록 구독
        viewModel.$newsItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                // 1. [추가] ⭐️ ViewModel에 데이터가 들어왔는지 확인
                print("--- ⭐️ [ViewModel] newsItems가 업데이트되었습니다. (총 \(items.count)개) ⭐️ ---")
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // 9. 로딩 및 에러 구독 (필요시)
    }
}

// 10. [추가] UITableView 델리게이트 / 데이터소스
extension AdmissionsNewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2. [추가] ⭐️ 테이블뷰가 몇 개의 행을 그릴지 확인
        print("--- ⭐️ [TableView] numberOfRowsInSection: \(viewModel.newsItems.count)개 ⭐️ ---")
        return viewModel.newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3. [추가] ⭐️ 셀을 실제로 생성하는지 확인
        print("--- ⭐️ [TableView] cellForRowAt: \(indexPath.row)번째 셀 생성 ⭐️ ---")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let newsItem = viewModel.newsItems[indexPath.row]
        cell.configure(with: newsItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsItem = viewModel.newsItems[indexPath.row]
        if let url = URL(string: newsItem.link) {
            // 11. 탭하면 인앱 브라우저로 기사 링크 열기
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// 12. [추가] (임시) 뉴스 테이블뷰 셀
class NewsCell: UITableViewCell {
    func configure(with item: NewsItem) {
        self.textLabel?.text = item.cleanedTitle
        self.detailTextLabel?.text = item.cleanedDescription
        self.textLabel?.numberOfLines = 2
        self.detailTextLabel?.numberOfLines = 3
    }
    // (UITableViewCell 기본 스타일을 사용하도록 임시 설정. 나중에 커스텀)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
