//
//  MainViewController.swift
//  RxSwiftEx-1
//
//  Created by Bran on 2022/07/09.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class MainViewController: UIViewController {

  let mainView = MainView()
  let disposeBag = DisposeBag()
  var shownCities = [String]()
  let allCities = ["New York", "London", "Oslo", "Warsaw", "Berlin", "Praga"]

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupConstraints()
    setupTableView()
    bind()
  }

  func setupView() {
    view.backgroundColor = .white
    view.addSubview(mainView)
  }

  func setupConstraints() {
    mainView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }

  func setupTableView() {
    mainView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    mainView.tableView.dataSource = self
  }

  func bind() {
    mainView.searchBar
      .rx.text
      .orEmpty
      .filter { !$0.isEmpty }
      .subscribe(onNext: { [unowned self] query in
        self.shownCities = self.allCities.filter { $0.hasPrefix(query) }
        self.mainView.tableView.reloadData()
      })
      .disposed(by: disposeBag)
  }

}

extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shownCities.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = shownCities[indexPath.row]
    return cell
  }
}
