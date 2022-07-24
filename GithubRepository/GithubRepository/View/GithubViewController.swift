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
    textFieldTapAction: githubView.textField.rx.controlEvent([.editingDidEndOnExit])
      .withLatestFrom(githubView.textField.rx.text) { $1 ?? "" }
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
      .drive(githubView.tableView.rx.items) { tableView, row, element in
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

    output.errorValue
      .drive(onNext: { [weak self] error in
        let alert = UIAlertController(
          title: "Can't Find Organization",
          message: error.localizedDescription,
          preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Close", style: .default)
        alert.addAction(action)
        self?.present(alert, animated: true)
      })
      .disposed(by: disposeBag)

  }
}
