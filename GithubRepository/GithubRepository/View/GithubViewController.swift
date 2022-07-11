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
  let githubView = GithubView()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupConstraints()
    NetworkManager.shared.requestRepository("Apple")
      .subscribe {
        print($0)
      }
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

}
