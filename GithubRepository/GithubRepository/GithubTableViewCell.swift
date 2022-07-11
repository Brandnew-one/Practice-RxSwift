//
//  GithubTableViewCell.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/11.
//

import UIKit

import SnapKit

class GithubTableViewCell: UITableViewCell {
  static let identifier = "GithubTableViewCell"

  let titleLabel = UILabel()
  let descriptionLabel = UILabel()
  let starImageView = UIImageView()
  let startCountLabel = UILabel()
  let languageLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("GithubCell Error")
  }

  func configureCell() {
    print("configure")
  }

  private func setupView() {
    [
      titleLabel, descriptionLabel, starImageView,
      startCountLabel, languageLabel
    ].forEach {
      contentView.addSubview($0)
    }
  }

  private func setupConstraints() {
    starImageView.snp.makeConstraints {
      $0.height.width.equalTo(20)
      $0.leading.equalToSuperview().offset(18)
      $0.bottom.equalToSuperview().offset(-18)
    }

    startCountLabel.snp.makeConstraints {
      $0.leading.equalTo(starImageView.snp.trailing).offset(8)
      $0.bottom.equalTo(starImageView.snp.bottom)
    }

    languageLabel.snp.makeConstraints {
      $0.leading.equalTo(startCountLabel.snp.trailing).offset(8)
      $0.trailing.greaterThanOrEqualToSuperview().offset(-8) // MARK: -
      $0.bottom.equalTo(starImageView.snp.bottom)
    }

    descriptionLabel.snp.makeConstraints {
      $0.bottom.equalTo(starImageView.snp.top).offset(-8)
      $0.leading.equalTo(starImageView.snp.leading)
      $0.trailing.equalToSuperview().offset(-8)
    }

    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(starImageView.snp.leading)
      $0.bottom.equalTo(descriptionLabel.snp.top).offset(-18)
      $0.trailing.equalToSuperview().offset(-8)
    }
  }
}
