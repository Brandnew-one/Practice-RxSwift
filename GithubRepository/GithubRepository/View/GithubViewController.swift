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
    githubView.textField.rx.controlEvent([.editingDidEndOnExit])
      .subscribe(onNext: { [weak self] in
        guard let text = self?.githubView.textField.text else { return }
        self?.githubViewModel.fetchGithub(text)
      })
      .disposed(by: disposeBag)

    githubViewModel.githubList
      .bind(to: githubView.tableView.rx.items) { tableView, row, element in
        guard
          let cell = tableView.dequeueReusableCell(
            withIdentifier: GithubTableViewCell.identifier
          ) as? GithubTableViewCell
        else {
          return UITableViewCell()
        }
        cell.configureCell(element)
        return cell
      }
      .disposed(by: disposeBag)
  }
}
