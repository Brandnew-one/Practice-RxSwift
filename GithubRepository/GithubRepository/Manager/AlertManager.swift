//
//  AlertManager.swift
//  GithubRepository
//
//  Created by Bran on 2022/07/25.
//

import UIKit

class AlertManager {
  public static let shared = AlertManager()

  private init() { }

  func topViewController(
    title: String,
    message: String
  ) {
    DispatchQueue.main.async {
      let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
      if var topController = keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController { topController = presentedViewController }
        let alert = UIAlertController(
          title: title,
          message: message,
          preferredStyle: .alert
        )

        let action = UIAlertAction(title: "Close", style: .default)
        alert.addAction(action)
        topController.present(alert, animated: true)
      }
    }
  }
}
