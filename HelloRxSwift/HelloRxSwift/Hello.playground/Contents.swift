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

// Observable의 life Cycle이 종료되었기 때문에 바로종료
let o3 = subject.subscribe { print(">>3", $0) }
subject.onNext("test")
o3.disposed(by: disposeBag)


// MARK: -

// 하나의 값을 방출하는 경우
Observable.just("🤦")
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)

Observable.just([1, 2, 3]) // 그대로 방출함
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)

// 하나이상의 값을 방출하는 경우
Observable.of(1, 2, 3) // 가변 파라미터로 선언되어 있음
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)

// 배열을 방출하는 경우?
Observable.from([1, 2, 3])
  .subscribe { event in print(event) }
  .disposed(by: disposeBag)

// MARK: -

let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

Observable.from(numbers)
  .filter { $0 % 2 == 0 }
  .subscribe { print( $0) }
  .disposed(by: disposeBag)


let a = BehaviorSubject(value: 1)
let b = BehaviorSubject(value: 2)

let subjects = PublishSubject<BehaviorSubject<Int>>()
subjects
  .flatMap { $0.asObservable() }
  .subscribe { print($0) }
  .disposed(by: disposeBag)

subjects.onNext(a)
subjects.onNext(b)

// MARK: -

let greetings = PublishSubject<String>()
let lanuages = PublishSubject<String>()

Observable.combineLatest(greetings, lanuages) { lhs, rhs
  -> String in
  return "\(lhs) \(rhs)"
}
.subscribe{ print($0) }
.disposed(by: disposeBag)

greetings.onNext("Hi")
lanuages.onNext("World")
greetings.onNext("Hello")
greetings.onCompleted()
//greetings.onError(MyError.error)
lanuages.onNext("SwiftUI")
lanuages.onCompleted()
// completed는 2개 다 complete가 와야 되지만
// error는 둘 중 하나만 오면 된다


