import Foundation
import RxSwift


let disposeBag = DisposeBag()

print("----------toArray-------------")
Observable.of("1", "2", "3")
  .toArray() // Single로 바뀜
  .subscribe(onSuccess: { // Single이기 때문에 onSuccess
    print($0)
  })
  .disposed(by: disposeBag)

print("----------map-------------")
Observable.of(Date())
  .map { date -> String in
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "ko_KR")
    return dateFormatter.string(from: date)
  }
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

print("----------flatMap-----------")
protocol 선수 {
  var 점수: BehaviorSubject<Int> { get }
}

struct 양궁선수: 선수 {
  var 점수: BehaviorSubject<Int>
}

let 한국국가대표 = 양궁선수(점수: BehaviorSubject<Int>(value: 10))
let 중국국가대표 = 양궁선수(점수: BehaviorSubject<Int>(value: 1))

let 올림픽 = PublishSubject<선수>()
올림픽
  .flatMap { 선수 in
    선수.점수
  }
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

올림픽.onNext(한국국가대표)
한국국가대표.점수.onNext(9)

올림픽.onNext(중국국가대표)
한국국가대표.점수.onNext(8)
중국국가대표.점수.onNext(2)

print("----------flatMapLatest-----------")
struct 높이뛰기선수: 선수 {
  var 점수: BehaviorSubject<Int>
}

let 서울 = 높이뛰기선수(점수: BehaviorSubject<Int>(value: 10))
let 울산 = 높이뛰기선수(점수: BehaviorSubject<Int>(value: 0))
let 전국체전 = PublishSubject<선수>()

전국체전
  .flatMapLatest { 선수 in
    선수.점수
  }
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

전국체전.onNext(서울)
서울.점수.onNext(9)

전국체전.onNext(울산)
서울.점수.onNext(8) // 해당값이 무시되는 것을 확인할 수 있음
울산.점수.onNext(1)


print("------materialize & dameterialize------")
enum 반칙: Error {
  case 부정출발
}

struct 달리기선수: 선수 {
  var 점수: BehaviorSubject<Int>
}

let 신씨 = 달리기선수(점수: BehaviorSubject<Int>(value: 10))
let 이씨 = 달리기선수(점수: BehaviorSubject<Int>(value: 0))
let 달리기시합 = BehaviorSubject<선수>(value: 신씨)

달리기시합
  .flatMapLatest { 선수 in
    선수.점수
      .materialize() // 이벤트를 감싸줌
  }
  .filter {
    guard let error = $0.error else {
      return true
    }
    print(error)
    return false
  }
  .dematerialize()
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

신씨.점수.onNext(1)
신씨.점수.onError(반칙.부정출발)
신씨.점수.onNext(2)

달리기시합.onNext(이씨)



