//
//  AdmissionsNewsViewController.swift
//  I-Gou
//
//  Created by 장주진 on 9/23/25.
//

import UIKit
import Combine
import SafariServices

class AdmissionsNewsViewController: UIViewController {
    
    private var viewModel: AdmissionsNewsViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tableView = UITableView()
    
    // [추가] 1. 날짜 포맷을 위한 DateFormatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // (예: "Tue, 11 Nov 2025 15:57:00 +0900")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        return formatter
    }()
    
    private let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

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
        
        setupTableView()
        bindViewModel()
        
        viewModel.fetchNews()
    }
    
    // [수정] 2. ⭐️ 테이블뷰 스타일 수정
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewsCell.self, forCellReuseIdentifier: "NewsCell") // 3. ⭐️ (새로운 NewsCell)
        
        // 4. ⭐️ 스타일링
        tableView.separatorStyle = .none // 셀 사이의 선 제거
        tableView.backgroundColor = .clear // 배경을 투명하게
        tableView.showsVerticalScrollIndicator = false
        
        // 5. ⭐️ 동적 높이 설정
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            // 6. ⭐️ 좌우 패딩을 20으로 설정 (UniversityView와 동일하게)
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$newsItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                print("--- ⭐️ [ViewModel] newsItems가 업데이트되었습니다. (총 \(items.count)개) ⭐️ ---")
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // [추가] 7. ⭐️ 날짜 문자열을 "yyyy.MM.dd"로 변환
    private func formatNewsDate(_ dateString: String) -> String {
        if let date = dateFormatter.date(from: dateString) {
            return outputDateFormatter.string(from: date)
        }
        return dateString // 파싱 실패 시 원본 반환
    }
}

// 8. [수정] ⭐️ 델리게이트 / 데이터소스 (셀 설정 부분)
extension AdmissionsNewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // [수정] ⭐️ NewsCell로 캐스팅
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let newsItem = viewModel.newsItems[indexPath.row]
        
        // [수정] ⭐️ 날짜 포맷 적용
        let formattedDate = formatNewsDate(newsItem.pubDate)
        cell.configure(with: newsItem, date: formattedDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsItem = viewModel.newsItems[indexPath.row]
        // 9. [수정] ⭐️ 원본 링크(originallink)를 여는 것이 더 좋음
        if let url = URL(string: newsItem.originallink) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//
// 10. [수정] ⭐️ NewsCell 클래스 전체 교체
//
class NewsCell: UITableViewCell {
    
    // 1. 카드 UI
    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground // 카드 배경색
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 2. 제목
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2 // 최대 2줄
        return label
    }()
    
    // 3. 내용
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3 // 최대 3줄
        return label
    }()
    
    // 4. 날짜
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    // 5. 스택뷰
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8 // 요소 간 간격
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellUI() {
        // 6. ⭐️ 셀 자체는 투명하게
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 7. ⭐️ 뷰 계층: contentView > cardContainerView > stackView
        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(dateLabel)
        
        // 8. ⭐️ 레이아웃 설정
        NSLayoutConstraint.activate([
            // cardContainerView를 contentView에 부착 (상하좌우 여백)
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // stackView를 cardContainerView에 부착 (내부 여백)
            stackView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -16)
        ])
    }
    
    // 9. ⭐️ 셀 설정 함수
    func configure(with item: NewsItem, date: String) {
        titleLabel.text = item.cleanedTitle
        descriptionLabel.text = item.cleanedDescription
        dateLabel.text = date
    }
    
    // (선택) 셀이 눌렸을 때 시각적 효과
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) {
            self.cardContainerView.transform = highlighted ? .init(scaleX: 0.98, y: 0.98) : .identity
            self.cardContainerView.alpha = highlighted ? 0.8 : 1.0
        }
    }
}
