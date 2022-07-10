import Foundation
import RxSwift


print("-----just------")
Observable<Int>.just(1)
  .subscribe(onNext: {
    print($0)
  })


print("-----of------")
Observable<Int>.of(1, 2, 3, 4, 5)
  .subscribe(onNext: {
    print($0)
  })


print("-----of------")
Observable<[Int]>.of([1, 2, 3, 4, 5])
  .subscribe(onNext: {
    print($0)
  })

print("-----from------")
Observable<Int>.from([1, 2, 3, 4, 5])
  .subscribe(onNext: {
    print($0)
  })


print("-----subscribe1------")
Observable<Int>.of(1, 2, 3)
  .subscribe {
    print($0)
  }

print("-----subscribe2------")
Observable<Int>.of(1, 2, 3)
  .subscribe {
    if let element = $0.element {
      print(element)
    }
  }

print("-----subscribe3------")
Observable<Int>.of(1, 2, 3)
  .subscribe(onNext: {
    print($0)
  })

// Type이 없는 경우, completed 이벤트가 발생하지 않음
print("-----Empty------")
Observable<Void>.empty()
  .subscribe {
    print($0)
  }

// 아무것도 방출하지 않는 것을 확인할 수 있음
print("-----Never------")
Observable<Void>.never()
  .subscribe {
    print($0)
  }

print("-----range------")
Observable.range(start: 1, count: 9)
  .subscribe(onNext: {
    print("2 * \($0) = \(2 * $0)")
  })

print("-----Create1------")
let disposeBag = DisposeBag()
Observable.create { observer -> Disposable in
  observer.on(.next(1))
  observer.on(.completed)
  observer.on(.next(2)) // 이미 생명주기 종료되었기 때문에 방출되지 않음
  return Disposables.create()
}
.subscribe {
  print($0)
}

print("-----Create2------")
enum MyError: Error {
  case anError
}
Observable.create { observer -> Disposable in
  observer.on(.next(1))
  observer.on(.error(MyError.anError))
  observer.on(.next(2)) // 이미 생명주기 종료되었기 때문에 방출되지 않음
  return Disposables.create()
}
.subscribe(
  onNext: {
    print($0)
  },
  onError: {
    print($0.localizedDescription)
  },
  onCompleted: {
    print("completed")
  },
  onDisposed: {
    print("disposed")
  }
)
.disposed(by: disposeBag)


print("-----deferred1------")
Observable.deferred {
  Observable.of(1, 2, 3)
}
.subscribe {
  print($0)
}
.disposed(by: disposeBag)

print("-----deferred2------")
var flag = false
let factory: Observable<String> = Observable.deferred {
  flag.toggle()
  if flag {
    return Observable.just("🤚")
  } else {
    return Observable.just("👊")
  }
}

for i in 0...3 {
  factory.subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)
}
