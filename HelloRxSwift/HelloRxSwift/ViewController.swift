//
//  ViewController.swift
//  HelloRxSwift
//
//  Created by Bran on 2022/06/30.
//

import UIKit

import RxCocoa
import RxSwift

class ViewController: UIViewController {

  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var label: UILabel!
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    label.text = ""
    textField.becomeFirstResponder()

//     Main-Thread에서 실행되는가?
//    textField.rx.text
//      .observeOn(MainScheduler.instance)
//      .subscribe(onNext: { [weak self] str in
//        self?.label.text = str
//      })
//      .disposed(by: disposeBag)

    textField.rx.text
      .bind(to: label.rx.text) // 메인쓰레드를 직접 지정하지 않아도 된다
      .disposed(by: disposeBag)
  }

}

