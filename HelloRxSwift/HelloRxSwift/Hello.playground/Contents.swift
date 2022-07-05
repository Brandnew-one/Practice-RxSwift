import UIKit

import RxSwift

let disposeBag = DisposeBag()

Observable.just("Hello, RxSwift")
  .subscribe { print($0) }
  .disposed(by: disposeBag)

// Observable - Observer

// MARK: - Observable을 생성하는 방법

// 1)
Observable<Int>.create { (observer) -> Disposable in
  observer.on(.next(0))
  observer.onNext(1)
  observer.onCompleted() // 이후에 다른 이벤트를 전달할 수 없음
  return Disposables.create()
}

// 2)
Observable.from([0, 1])


// MARK: -
enum MyError: Error {
  case error
}

let subject = PublishSubject<String>() // Observable & Observer
subject.onNext("Hello") // 구독하기 전에 발생한 이벤트는 무시된다!

let o1 = subject.subscribe { print(">> 1", $0) }
o1.disposed(by: disposeBag)

subject.onNext("RxSwift")

let o2 = subject.subscribe { print(">>2", $0) }
o2.disposed(by: disposeBag)

subject.onNext("Subject")
//subject.onCompleted()
subject.onError(MyError.error)

let o3 = subject.subscribe { print(">>3", $0) }
o3.disposed(by: disposeBag)


// MARK: -
Observable.just("🤦")
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)

Observable.just([1, 2, 3]) // 그대로 방출함
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)

Observable.of(1, 2, 3)
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)

Observable.from([1, 2, 3])
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)

