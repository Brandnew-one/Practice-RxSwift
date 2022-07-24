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

final class GithubViewModel {
  private var disposeBag = DisposeBag()

  struct Input {
    let textFieldTapAction: Observable<String>
  }

  struct Output {
    let organizationValue: Driver<[Github]>
  }

  func transform(input: Input) -> Output {
    let organizationValue = input.textFieldTapAction
      .flatMap { [weak self] organization -> Observable<[Github]> in
        guard let self = self else { return .empty() }
        return self.fetchGithub(organization)
      }
      .asDriver(onErrorJustReturn: [])
    return Output(
      organizationValue: organizationValue
    )
  }
}

extension GithubViewModel {
  func fetchGithub(_ organization: String) -> Observable<[Github]> {
    NetworkManager.shared.requestRepository(organization)
      .catch { error in // catch 위치 여기인 이유 항상 생각하기
        AlertManager.shared.topViewController(title: "Error", message: error.localizedDescription)
        return .empty()
      }
  }
}
