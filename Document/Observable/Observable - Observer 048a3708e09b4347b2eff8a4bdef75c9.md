# Observable - Observer

### **Every `Observable` sequence is just a sequence.**

> **The key advantage for an `Observable` vs Swift's `Sequence` is that it can also receive elements asynchronously.**
> 

공식문서를 따르면 Observable은 swift의 Sequence와 동일하지만 비동기적으로 elements를 받을 수 있다는 차이점이 있다.

```swift
enum Event<Element>  {
    case next(Element)      // next element of a sequence
    case error(Swift.Error) // sequence failed with error
    case completed          // sequence terminated successfully
}

class Observable<Element> {
    func subscribe(_ observer: Observer<Element>) -> Disposable
}

protocol ObserverType {
    func on(_ event: Event<Element>)
```

Observable은 위와 같이 세 가지 유형의 이벤트만 방출하는데 error나 completed 이벤트가 방출되면 Observable의 시퀀스가 종료된다. (생명주기 끝)

---

## Observable 생성 메서드

### 1) just

![스크린샷 2022-07-13 오후 11.46.37.png](Observable%20-%20Observer%20048a3708e09b4347b2eff8a4bdef75c9/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-07-13_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_11.46.37.png)

하나의 요소를 포함하는 시퀀스 생성

```swift
Observable<Int>.just(1)
  .subscribe {
    print($0)
  }

// next(1)
//completed
```

### 2) of

![스크린샷 2022-07-13 오후 11.45.10.png](Observable%20-%20Observer%20048a3708e09b4347b2eff8a4bdef75c9/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-07-13_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_11.45.10.png)

element = 가변 파라미터, 타입 추론을 통해 시퀀스 생성 → Array타입 하나만 넣으면 하나만 방출

```swift
Observable<Int>.of(1, 2, 3, 4, 5)
  .subscribe(onNext: {
    print($0)
  })

// 1
// 2
// 3
// 4
// 5

Observable<[Int]>.of([1, 2, 3, 4, 5])
  .subscribe(onNext: {
    print($0)
  })

// [1, 2, 3, 4, 5]
```

### 3) from

![스크린샷 2022-07-14 오전 12.51.59.png](Observable%20-%20Observer%20048a3708e09b4347b2eff8a4bdef75c9/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-07-14_%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB_12.51.59.png)

Array 타입을 받아서 각 요소를 방출하는 시퀀스 생성

```swift
Observable<Int>.from([1, 2, 3, 4, 5])
  .subscribe(onNext: {
    print($0)
  })

// 1
// 2
// 3
// 4
// 5
```

### 4) create

![스크린샷 2022-07-14 오전 1.15.27.png](Observable%20-%20Observer%20048a3708e09b4347b2eff8a4bdef75c9/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-07-14_%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB_1.15.27.png)

Observable 시퀀스를 직접 생성~~(근본)~~

```swift
Observable.create { observer -> Disposable in
  observer.on(.next(1))
  observer.on(.next(2))
  observer.on(.completed)
  observer.on(.next(3)) // 이미 생명주기 종료되었기 때문에 방출되지 않음
  return Disposables.create()
}
.subscribe(
  onNext: {
    print($0)
  },
  onCompleted: {
    print("completed")
  }
)
.disposed(by: disposeBag)

// 1
// 2
// completed
```

next, completed, error 이벤트를 이용해 직접 시퀀스를 생성해 낼 수 있다.

### 5) empty

![스크린샷 2022-07-14 오후 3.08.17.png](Observable%20-%20Observer%20048a3708e09b4347b2eff8a4bdef75c9/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-07-14_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_3.08.17.png)

아무런 이벤트도 방출하지 않는 Observable을 생성한다

```swift
Observable<Void>.empty()
  .subscribe {
    print($0)
  }
// Completed
```

즉시 종료되는 Observable을 반환하거나, 의도적으로 빈 값을 만들어 낼 때 사용한다. 실제로는 옵셔널 바인딩 실패시 비어있는 Observable을 반환할 때도 사용한다.

### 6) never

![스크린샷 2022-07-14 오후 3.11.06.png](Observable%20-%20Observer%20048a3708e09b4347b2eff8a4bdef75c9/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-07-14_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_3.11.06.png)

empty와 유사해 보이지만 empty로 생성된 Observable의 경우 complete 이벤트는 방출되어 Observable의 생명주기가 끝나지만 never는 complete 이벤트도 방출하지 않아 시퀀스가 종료되지 않는다.

```swift
Observable<Void>.never()
  .subscribe {
    print($0)
  }
// 
```

어떤 상황에서 사용하는지 감이 오지 않아 찾아보니 This observable is primarily used for testing and not used in production. 네 그렇다고 합니다..

### 7) range

![스크린샷 2022-07-14 오후 3.13.51.png](Observable%20-%20Observer%20048a3708e09b4347b2eff8a4bdef75c9/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-07-14_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_3.13.51.png)

연속적인 정수의 범위를 방출하는 Observable 생성

```swift
Observable.range(start: 1, count: 9)
  .subscribe(onNext: {
    print("2 * \($0) = \(2 * $0)")
  })

// 2 * 1 = 2
// 2 * 2 = 4
// 2 * 3 = 6
// 2 * 4 = 8
// 2 * 5 = 10
// 2 * 6 = 12
// 2 * 7 = 14
// 2 * 8 = 16
// 2 * 9 = 18
```