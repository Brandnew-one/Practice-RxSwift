//
//  GithubViewController.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/11.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class GithubViewController: UIViewController {
  private var disposeBag = DisposeBag()
  private lazy var input = GithubViewModel.Input(
    textFieldTapAction: githubView.textField.rx.controlEvent(.editingDidEndOnExit)
      .withLatestFrom(githubView.textField.rx.text.orEmpty)
      .filter { !$0.isEmpty }
      .distinctUntilChanged()
  )
  private lazy var output = githubViewModel.transform(input: input)

  let githubView = GithubView()
  let githubViewModel = GithubViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupConstraints()
    setupTableView()
    bind()
  }

  func setupView() {
    view.backgroundColor = .white
    view.addSubview(githubView)
  }

  func setupConstraints() {
    githubView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }

  func setupTableView() {
    githubView.tableView.rowHeight = 140
    githubView.tableView.register(GithubTableViewCell.self, forCellReuseIdentifier: GithubTableViewCell.identifier)
  }

  func bind() {
    output.organizationValue
      .drive(
        githubView.tableView.rx.items(
          cellIdentifier: GithubTableViewCell.identifier,
          cellType: GithubTableViewCell.self
        )
      ) { row, item, cell in
        cell.configureCell(item)
      }
      .disposed(by: disposeBag)
  }
}
