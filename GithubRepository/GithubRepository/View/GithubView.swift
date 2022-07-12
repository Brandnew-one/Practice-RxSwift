//
//  GithubView.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/12.
//

import UIKit

import SnapKit

class GithubView: UIView {
  let textField = UITextField()
  let tableView = UITableView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupTextField()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("Github View Error")
  }

  private func setupView() {
    self.addSubview(tableView)
    self.addSubview(textField)
  }

  private func setupTextField() {
    textField.borderStyle = .roundedRect
  }

  private func setupConstraints() {
    textField.snp.makeConstraints {
      $0.leading.top.equalToSuperview().offset(8)
      $0.trailing.equalToSuperview().offset(-8)
//      $0.height.equalTo(80)
    }

    tableView.snp.makeConstraints {
      $0.top.equalTo(textField.snp.bottom).offset(8)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }

}
