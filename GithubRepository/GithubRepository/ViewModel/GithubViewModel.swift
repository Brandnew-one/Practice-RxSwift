//
//  GithubViewModel.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/12.
//

import Foundation

import RxCocoa
import RxSwift
import RxRelay

class GithubViewModel {

  private var disposeBag = DisposeBag()
  let githubList = PublishSubject<[Github]>()
  let errorList = PublishSubject<Error>()

  struct Input {
    let textFieldTapAction: Observable<String>
  }

  struct Output {
    let organizationValue: Driver<[Github]>
    let errorValue: Driver<Error>
  }

  func transform(input: Input) -> Output {
    input.textFieldTapAction
      .subscribe(onNext: { [weak self] find in
        self?.fetchGithub(find)
      })
      .disposed(by: disposeBag)

    return Output(
      organizationValue: githubList.asDriver(onErrorJustReturn: []),
      errorValue: errorList.asDriver(onErrorJustReturn: NetworkError.default)
    )
  }
}

extension GithubViewModel {
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
