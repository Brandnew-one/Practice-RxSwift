//
//  MainView.swift
//  RxSwiftEx-1
//
//  Created by Bran on 2022/07/09.
//

import UIKit

import SnapKit

class MainView: UIView {
  let searchBar = UISearchBar()
  let tableView = UITableView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("MainView Error")
  }

  func setupView() {
    [searchBar, tableView].forEach {
      self.addSubview($0)
      $0.backgroundColor = .white
    }
  }

  func setupConstraints() {
    searchBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(20)
      $0.height.equalTo(100)
    }

    tableView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.top.equalTo(searchBar.snp.bottom).offset(8)
    }
  }

}
