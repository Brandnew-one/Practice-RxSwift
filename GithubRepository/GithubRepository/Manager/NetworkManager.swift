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
  case invalidResponse(URLResponse?)
  case invalidJSON
}

class NetworkManager {
  static let shared = NetworkManager()

  private init() { }

  func requestRepository(_ organization: String) -> Observable<[Github]> {
    let urlStr = "https://api.github.com/orgs/\(organization)/repos"
    return Observable.just(urlStr)
      .map { URL(string: $0)! }
      .map { URLRequest(url: $0) }
      .flatMap { URLSession.shared.rx.response(request: $0) }
      .map { (result, data) -> Data in
        if result.statusCode == 200 {
          return data
        } else {
          throw NetworkError.invalidResponse(result)
        }
      }
      .map { data -> [Github] in
        guard
          let githubData = try? JSONDecoder().decode([Github].self, from: data)
        else {
          throw NetworkError.invalidJSON
        }
        return githubData
      }
  }
}
