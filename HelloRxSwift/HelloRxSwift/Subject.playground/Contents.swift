import Foundation
import RxSwift

let disposeBag = DisposeBag()

print("-------PublishSubject---------")
let publishSubject = PublishSubject<String>()

publishSubject.onNext("1. Hi")

let subsriber1 = publishSubject
  .subscribe(onNext: {
    print("첫번째 구독자", $0)
  })

publishSubject.onNext("2. Hello?")
publishSubject.onNext("3. Hey!")
//subsriber1.disposed(by: disposeBag) // disposed <-> dispose
subsriber1.dispose()

let subsriber2 = publishSubject
  .subscribe(onNext: {
    print("두번째 구독자", $0)
  })


publishSubject.onNext("4. :)")
publishSubject.onCompleted()
publishSubject.onNext("5. Done")

subsriber2.dispose()

publishSubject
  .subscribe {
    print("세번째 구독:", $0.element ?? $0)
  }
  .disposed(by: disposeBag)

publishSubject.onNext("6. Done")



enum SubjectError: Error {
  case behaviorError
}
print("-------BehavoirSubject---------")

let behaviorSubject = BehaviorSubject<String>(value: "init Value")
behaviorSubject.onNext("1. first Value") // 구독 이전의 첫번째 값을 가져오는 것을 확인 할 수 있음

behaviorSubject
  .subscribe {
    print("첫번째 구독", $0)
  }
  .disposed(by: disposeBag)

behaviorSubject.onError(SubjectError.behaviorError)

behaviorSubject
  .subscribe {
    print("두번째 구독", $0)
  }
  .disposed(by: disposeBag)

let value = try? behaviorSubject.value()
print(value) // 가장 최신 이벤트 값


print("-------ReplaySubject---------")
let replaySubject = ReplaySubject<String>.create(bufferSize: 2)

replaySubject.onNext("1. RxSwift")
replaySubject.onNext("2. Too Hard")
replaySubject.onNext("3. ㅠㅠ")

replaySubject.subscribe {
  print("첫번째 구독:", $0)
}
.disposed(by: disposeBag)

replaySubject.subscribe {
  print("두번째 구독:", $0)
}
.disposed(by: disposeBag)

replaySubject.onNext("4. 해야지해야지...")
replaySubject.onError(SubjectError.behaviorError)
replaySubject.dispose()

replaySubject.subscribe {
  print("세번째 구독:", $0)
}
.disposed(by: disposeBag)
