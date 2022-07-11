//
//  Github.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/12.
//

import Foundation

struct Github: Codable {
  let id: Int
  let name: String
  let description: String?
  let stargazersCount: Int
  let language: String

  enum CodingKeys: String, CodingKey {
    case id, name, description, language
    case stargazersCount = "stargazers_count"
  }
}

