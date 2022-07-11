//
//  GithubView.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/12.
//

import UIKit

import SnapKit

class GithubView: UIView {
  let tableView = UITableView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("Github View Error")
  }

  private func setupView() {
    self.addSubview(tableView)
  }

  private func setupConstraints() {
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

}
