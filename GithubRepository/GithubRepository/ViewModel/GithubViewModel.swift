//
//  GithubViewModel.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/12.
//

import Foundation

import RxSwift

class GithubViewModel {
  private var disposeBag = DisposeBag()
  let githubList = BehaviorSubject<[Github]>(value: [])

  let errorList = PublishSubject<Error>()

  func fetchGithub(_ organization: String) {
    NetworkManager.shared.requestRepository(organization)
      .subscribe(
        onSuccess: { [weak self] result in
          switch result {
          case .success(let data):
            self?.githubList.onNext(data)
          case .failure(let error):
            print(error)
          }
        },
        onFailure: { [weak self] error in
          self?.errorList.onNext(error)
        }
      )
      .disposed(by: disposeBag)
  }
}
