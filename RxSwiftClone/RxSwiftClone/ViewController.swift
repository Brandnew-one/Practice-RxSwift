//
//  ViewController.swift
//  RxSwiftClone
//
//  Created by Bran on 2022/07/05.
//

import UIKit
import RxSwift
import RxCocoa

class MyObservable<T> {
  private var _task: ((@escaping (T) -> Void) -> Void)?

  init(task: @escaping (_ execute: @escaping (T) -> Void) -> Void) {
    self._task = task
  }

  func subscribe(_ execute: @escaping (T) -> Void) {
    guard let task = _task else { return}
    DispatchQueue.global(qos: .background).async {
      task(execute)
    }
  }
}

extension MyObservable {
  static func create(
    _ task: @escaping (_ execute: @escaping (T) -> Void) -> Void
  ) -> MyObservable<T> {
    return MyObservable(task: task)
  }
}

extension MyObservable {
  static func just(_ value: T) -> MyObservable<T> {
    return MyObservable<T> { receiver in
      receiver(value)
    }
  }
}

extension MyObservable {
  static func from(_ value: [T]) -> MyObservable<T> {
    return MyObservable<T> { receiver in
      value.forEach { t in
        receiver(t)
      }
    }
  }
}

extension MyObservable {
  func map<U>(_ mapper: @escaping (T) -> U) -> MyObservable<U> {
    return MyObservable<U> { receiver in
      self.subscribe { t in
        receiver(mapper(t))
      }
    }
  }
}

extension MyObservable {
  func filter(_ filter: @escaping (T) -> Bool) -> MyObservable<T> {
    return MyObservable<T> { receiver in
      self.subscribe { t in
        if filter(t) {
          receiver(t)
        }
      }
    }
  }
}

extension MyObservable {
  func flatMap<U>(_ mapper: @escaping (T) -> MyObservable<U>) -> MyObservable<U> {
    return MyObservable<U> { receiver in
      self.subscribe { t in
        mapper(t).subscribe { u in
          receiver(u)
        }
      }
    }
  }
}

extension MyObservable {
  func filterNil<U>() -> MyObservable<U> where T == U? {
    return filter { $0 != nil }.map { $0! }
  }
}

extension MyObservable {
  func main() -> MyObservable<T> {
    return MyObservable<T> { receiver in
      self.subscribe { t in
        DispatchQueue.main.async {
          receiver(t)
        }
      }
    }
  }
}



class ViewController: UIViewController {

  func i2s(_ i: Int, _ cb: @escaping (String) -> Void) {
    DispatchQueue.global(qos: .background).async {
      cb("\(i)")
    }
  }

  //  func i2s(_ i: Int) -> String {
  //    DispatchQueue.global(qos: .background).async {
  //      return "\(i)"  //???
  //    }
  //  }

  //  func asyncImageDownload(_ url: URL) -> MyObservable<UIImage?> {
  //    return MyObservable.create { task in
  //      DispatchQueue.global().async {
  //        if let data = try Data(contentsOf: url),
  //           let image = UIImage(data: data) {
  //          task(Image)
  //        }
  //      }
  //    }
  //  }


  func generalAsyncFunction<T>(
    task: @escaping (_ result: @escaping (T) -> Void) -> Void,
    execute: @escaping (T) -> Void
  ) {
    DispatchQueue.global(qos: .background).async {
      task(execute)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    i2s(42) {
      print($0)
    }

    generalAsyncFunction(
      task: { cb in cb("\(42)") },
      execute: { s in print(s) }
    )

    let ob = MyObservable(task: { cb in cb("\(42)") })
    ob.subscribe { s in print(s) }

    MyObservable.create { execute in
      execute("\(42)")
    }
    .subscribe { s in
      print(s)
    }

    MyObservable.just(42)
      .subscribe { i in print(i) }

    MyObservable.from([42, 41, 40])
      .map { i in i * 3}
      .filter { $0 % 2 == 0 }
      .subscribe { i in
        print(i)
      }

    let imageView = UIImageView()
    view.addSubview(imageView)
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    MyObservable.just(1024)
      .map { size in "https://random.imagecdn.app/\(size)/\(size)" }
      .map { URL(string: $0) }
      .filterNil()
      .flatMap { url in self.download(url: url) }
      .filterNil()
      .map { data in UIImage(data: data) }
      .main()
      .subscribe { [weak imageView] image in
        imageView?.image = image
      }
  }

  func download(url: URL) -> MyObservable<Data?> {
    return MyObservable.create { receiver in
      receiver(try? Data(contentsOf: url))
    }
  }
}
