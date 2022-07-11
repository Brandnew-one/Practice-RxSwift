//
//  NetworkManager.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/12.
//

import Foundation

import RxSwift

enum NetworkError: Error {
  case `default`
}

class NetworkManager {
  static let shared = NetworkManager()

  private init() { }

  func requestRepository(_ organization: String) -> Single<Result<[Github], Error>> {
    let urlStr = "https://api.github.com/orgs/\(organization)/repos"
    return Observable.just(urlStr)
      .map { URL(string: $0)! }
      .map { URLRequest(url: $0) }
      .flatMap { URLSession.shared.rx.data(request: $0) }

      .map { data -> Result<[Github], Error> in
        guard
          let githubData = try? JSONDecoder().decode([Github].self, from: data)
        else {
          return .failure(NetworkError.default)
        }
        print(githubData)
        return .success(githubData)
      }
      .asSingle()
  }
}
