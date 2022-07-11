import Foundation
import RxSwift

let disposeBag = DisposeBag()

print("---------ignoreElements------------")
let 취침모드 = PublishSubject<String>() // Next 이벤트를 무시한다
취침모드
  .ignoreElements()
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)

취침모드.onNext("Wake Up")
취침모드.onNext("Wake Up")
취침모드.onNext("Wake Up")

취침모드.onCompleted()


print("---------elementAt------------")
let 두번울면깨는사람 = PublishSubject<String>() // 특정 index 이벤트만 방출한다
두번울면깨는사람
  .elementAt(2)
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

두번울면깨는사람.onNext("👏")
두번울면깨는사람.onNext("👏")
두번울면깨는사람.onNext("😾")
두번울면깨는사람.onNext("👏")

print("---------Filter------------")
Observable.of(1, 2, 3, 4, 5, 6)
  .filter { $0 % 2 == 0 }
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

print("---------Skip------------")
Observable.of(1, 2, 3, 4, 5, 6)
  .skip(5)
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

print("---------SkipWhile------------")
Observable.of(1, 2, 3, 4, 5, 6)
  .skip(while: {
    $0 != 3 // false가 될 때까지 event를 무시한다
  })
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

print("---------SkipUntil------------")
let 손님 = PublishSubject<String>()
let 문여는시간 = PublishSubject<String>()

손님
  .skip(until: 문여는시간) // 다른 Observable이 Next 이벤트를 방출하기 전까지
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

손님.onNext("1")
손님.onNext("2")

문여는시간.onNext("Opne!")
손님.onNext("3")
손님.onNext("4")

print("---------take------------") // Skip과 반대개념
Observable.of("1", "2", "3", "4", "5")
  .take(3)
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

print("---------takewhile------------")
Observable.of("1", "2", "3", "4", "5")
  .take(while: {
    $0 != "4" // false가 되는 시점부터 이벤트를 무시한다
  })
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

print("---------takeUntil------------")
let 수강신청 = PublishSubject<String>()
let 신청마감 = PublishSubject<String>()

수강신청
  .take(until: 신청마감) // 특정 Observable가 Next 이벤트가 발생하기 전까지 방출시킴
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

수강신청.onNext("1")
수강신청.onNext("2")
수강신청.onNext("3")

신청마감.onNext("마감!")
수강신청.onNext("4")

print("---------distinctUntilChanged------------")
Observable.of("1", "2", "3", "4", "4", "4", "4", "4", "1", "2", "3", "4")
  .distinctUntilChanged() // 이전값과 중복되는 경우 무시한다
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

print("---------enumerated------------") // 방출된 이벤트의 인덱스를 알고 싶은경우
Observable.of("1", "2", "3", "4", "5")
  .enumerated() // 튜플이 만들어짐
  .take(while: {
    $0.index < 3
  })
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

