# Filtering Operator

## 1) ignoreElements

next 이벤트를 무시하고 종료 event만 전달 해준다. 

```swift
// returns: An observable sequence that skips all elements of the source sequence.

  public func ignoreElements() -> Observable<Never> {
    self.flatMap { _ in Observable<Never>.empty() }
  }
```

Observable을 만드는 메서드 중에서 empty도 종료 이벤트만 방출하는 Observable을 만들었는데 굉장히 유사하다라고 생각했는데 실제 구현 코드를 확인해보면 flatMap을 통해서 현재 Observable을 empty로 변형하는 것을 확인할 수 있다.

```swift
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

// completed
```

## 2) element (= elementAt)

특정 인덱스의 이벤트만 방출한다(종료 이벤트는 방출한다)

```swift
let 두번울면깨는사람 = PublishSubject<String>() // 특정 index 이벤트만 방출한다
두번울면깨는사람
  .element(at: 2)
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

두번울면깨는사람.onNext("👏")
두번울면깨는사람.onNext("👏")
두번울면깨는사람.onNext("😾")
두번울면깨는사람.onNext("👏")

// 😾
```

## 3) filter

우리가 고차함수로 사용하던 filter와 유사하다. 우리가 만든 조건을 통과하는 이벤트(next)들을 걸러준다

```swift
Observable.of(1, 2, 3, 4, 5, 6)
  .filter { $0 % 2 == 0 }
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)
// 2
// 4
// 6
```

## 4) Skip

- skip(): 처음 발생하는 n개의 이벤트를 무시한다

```swift
Observable.of(1, 2, 3, 4, 5, 6)
  .skip(2)
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

// 3
// 4
// 5
// 6
```

- skip(while: ): 작성한 조건에 만족하는 경우 이벤트 무시, 하지만 단 한번이라도 조건을 만족하지 못하는 경우부터 이벤트를 방출한다

```swift
Observable.of(1, 2, 3, 4, 5, 6)
  .skip(while: {
    $0 != 3 // false가 될 때까지 event를 무시한다
  })
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

// 3
// 4
// 5
// 6
```

- skip(until: ): trigger가 되는 시퀀스에서 이벤트가 발생하기 전까지 발생하는 이벤트를 무시한다

```swift
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

// 3
// 4
```

## 5) take

take는 skip과 아예 반대로 생각하면 된다.

- take(): 입력한 개수 만큼 이벤트를 방출하고 그 이후부터 무시한다.

```swift
Observable.of("1", "2", "3", "4", "5")
  .take(3)
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

// 1
// 2
// 3
```

- take(while: ): 작성한 조건까지 이벤트를 방출한다(false가 되는 시점부터 이벤트를 무시)

```swift
Observable.of("1", "2", "3", "4", "5")
  .take(while: {
    $0 != "4" // false가 되는 시점부터 이벤트를 무시한다
  })
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

// 1
// 2
// 3
```

- take(until: ): trigger가 되는 시퀀스에서 이벤트가 발생하기 전까지 이벤트를 방출

```swift
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

// 1
// 2
// 3
```

## 6) distinctUntilChanged

바로 이전에 방출한 이벤트와 동일한 값일 경우 무시(중복 방지)

```swift
Observable.of("1", "2", "3", "4", "4", "4", "4", "4", "1", "2", "3", "4")
  .distinctUntilChanged() // 이전값과 중복되는 경우 무시한다
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)
// 1
// 2
// 3
// 4
// 1
// 2
// 3
// 4
```

## 7) enumerated

방출된 요소의 인덱스를 확인하고 싶을 경우, 우리가 Swift에서 사용하던것과 마찬가지로 튜플을 생성한다

```swift
Observable.of("1", "2", "3", "4", "5")
  .enumerated() // 튜플이 만들어짐
  .take(while: {
    $0.index < 3
  })
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

// (index: 0, element: "1")
// (index: 1, element: "2")
// (index: 2, element: "3")
```