//
//  GradeInputCell.swift
//  I-Gou
//
//  Created by 장주진 on 10/28/25.
//

import UIKit

// 셀 내부의 텍스트필드 값이 변경될 때 ViewController에 알리기 위한 Delegate
protocol GradeInputCellDelegate: AnyObject {
    func didChangeValue(in cell: GradeInputCell, subject: String?, score: String?, gradeLevel: String?)
}

class GradeInputCell: UITableViewCell {
    
    static let identifier = "GradeInputCell"
    weak var delegate: GradeInputCellDelegate?
    var indexPath: IndexPath? // 셀이 몇 번째 행인지 식별하기 위해

    let subjectTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "과목명"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    let scoreTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "점수"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()
    
    let gradeLevelTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "등급"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad // 1~9 등급
        return tf
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        // 셀 배경 투명하게
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [subjectTextField, scoreTextField, gradeLevelTextField])
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    private func setupActions() {
        // 텍스트필드 값이 변경될 때마다 delegate 호출
        subjectTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        scoreTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        gradeLevelTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        delegate?.didChangeValue(in: self,
                                 subject: subjectTextField.text,
                                 score: scoreTextField.text,
                                 gradeLevel: gradeLevelTextField.text)
    }
    
    // ViewController가 셀을 재사용할 때 데이터를 채워넣기 위한 함수
    func configure(subject: String?, score: String?, gradeLevel: String?) {
        subjectTextField.text = subject
        scoreTextField.text = score
        gradeLevelTextField.text = gradeLevel
    }
}
