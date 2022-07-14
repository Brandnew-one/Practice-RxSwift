# Observable

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

`예제 코드에 dispose가 없어서 불편하신가요? Observer정리에서 dispose에 대해 정리하면서 추가되오니 참아주세요`

---

## Observable 생성 메서드

### 1) just

<img width="458" alt="스크린샷_2022-07-13_오후_11 46 37" src="https://user-images.githubusercontent.com/88618825/178919698-576eaa81-7be9-4bf7-acf4-ce9670e9739a.png">

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

<img width="457" alt="스크린샷_2022-07-13_오후_11 45 10" src="https://user-images.githubusercontent.com/88618825/178919804-7a9be839-d96e-4a7c-a52a-4b5e3b7896c7.png">

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

<img width="460" alt="스크린샷_2022-07-14_오전_12 51 59" src="https://user-images.githubusercontent.com/88618825/178919869-8a1ed221-a95c-4282-9ad0-74182ef848e4.png">

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

<img width="459" alt="스크린샷_2022-07-14_오전_1 15 27" src="https://user-images.githubusercontent.com/88618825/178919948-49504c67-27bf-4faa-9a6b-1d8a0557a329.png">

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

<img width="477" alt="스크린샷_2022-07-14_오후_3 08 17" src="https://user-images.githubusercontent.com/88618825/178919999-70e2266c-9090-416e-a430-3be8fc832b0c.png">

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

<img width="459" alt="스크린샷_2022-07-14_오후_3 11 06" src="https://user-images.githubusercontent.com/88618825/178920084-2ba75e3d-88e4-4433-816d-7b92e9077370.png">

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

<img width="438" alt="스크린샷_2022-07-14_오후_3 13 51" src="https://user-images.githubusercontent.com/88618825/178920157-e80a5527-d15a-42c3-b24a-0d7d859a3004.png">

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
