# Combining Operator

## 1) startWith

> Prepends a sequence of values to an observable sequence.
> 

```swift
let observableInt = Observable.of(1, 2, 3, 4)
observableInt
  .startWith(-1, 0)
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

// -1
// 0
// 1
// 2
// 3
// 4
```

startWith의 매개변수가 가변 파라미터로 설정되어 있기 때문에 Observable 시퀀스를 기존의 Observable 시퀀스 앞쪽에 추가할 수 있다.

## 2) concat

> ****emit the emissions from two or more Observables without interleaving them****
> 

둘 이상의 Observable을 interleaving 하지 않고 방출한다. 

여기서 interleaving은 여러 Observable의 element를 동시에 방출하지 않는다? 정도로 이해했다.

> The Concat operator concatenates the output of multiple Observables so that they act like a single Observable, with all of the items emitted by the first Observable being emitted before any of the items emitted by the second Observable (and so forth, if there are more than two).
> 

공식 홈페이지 내용을 좀 더 살펴보면 여러개의 Observable을 하나의 Observable 처럼 동작하도록하고, 두번째 Observable이 방출되기 전에 첫번째 Observable 시퀀스가 모두 방출된다라고 한다. 즉 순서가 보장된다!

먼저 들어온 Observable 시퀀스가 모두 방출되고 다음 Observable 시퀀스가 방출되는 특성 때문에 Hot Observable 을 concat 하는 경우 Observable이 방출되는 것을 관찰하지 못할 수 있다.

```swift
let 노랑반어린이들 = Observable.of("어린이1", "어린이2", "어린이3")
let 선생님 = Observable.of("선생님1", "선생님2")

let 줄서서걷기 = Observable
    .concat([선생님, 노랑반어린이들])
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
// 선생님1
// 선생님2
// 어린이1
// 어린이2
// 어린이3

선생님
    .concat(노랑반어린이들)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
// 선생님1
// 선생님2
// 어린이1
// 어린이2
// 어린이3
```

## 3) concatMap

concatMap은 flatMap과 굉장히 유사하다. 하지만 거기에 앞서 확인한 concat의 특성이 추가된다.

```swift
let 노랑반어린이들 = Observable.of("어린이1", "어린이2", "어린이3")
let 선생님 = Observable.of("선생님1", "선생님2")

선생님
  .flatMap { str -> Observable<String> in
    노랑반어린이들.map { str + $0 }
  }
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)
```

결과가 어떻게 출력될지 예측되는가?

![스크린샷 2022-07-21 오후 5.05.55.png](Combining%20Operator%20246cbfff5c6d4cfca44e94b3f939dae3/%25E1%2584%2589%25E1%2585%25B3%25E1%2584%258F%25E1%2585%25B3%25E1%2584%2585%25E1%2585%25B5%25E1%2586%25AB%25E1%2584%2589%25E1%2585%25A3%25E1%2586%25BA_2022-07-21_%25E1%2584%258B%25E1%2585%25A9%25E1%2584%2592%25E1%2585%25AE_5.05.55.png)

복습 차원에서 그림을 그려보면 위와 같이 map에 의해서 2개의 Observable Sequence가 생성되고 flatMap에 의해서 하나의 Observable Sequence로 합쳐진다

```swift
// next(선생님1어린이1)
// next(선생님1어린이2)
// next(선생님2어린이1)
// next(선생님1어린이3)
// next(선생님2어린이2)
// next(선생님2어린이3)
// completed
```

그럼 concatMap의 결과를 예측해보자. concat은 먼저 들어온 Observable 시퀀스가 모두 방출되고 다음 Observable 시퀀스가 방출되어 순서가 보장된다.

```swift
선생님
  .concatMap { str -> Observable<String> in
    노랑반어린이들.map { str + $0 }
  }
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)

// next(선생님1어린이1)
// next(선생님1어린이2)
// next(선생님1어린이3)
// next(선생님2어린이1)
// next(선생님2어린이2)
// next(선생님2어린이3)
// completed
```

![스크린샷 2022-07-21 오후 5.16.35.png](Combining%20Operator%20246cbfff5c6d4cfca44e94b3f939dae3/%25E1%2584%2589%25E1%2585%25B3%25E1%2584%258F%25E1%2585%25B3%25E1%2584%2585%25E1%2585%25B5%25E1%2586%25AB%25E1%2584%2589%25E1%2585%25A3%25E1%2586%25BA_2022-07-21_%25E1%2584%258B%25E1%2585%25A9%25E1%2584%2592%25E1%2585%25AE_5.16.35.png)

결과가 자명타!

## 4) merge

> ****combine multiple Observables into one by merging their emissions****
> 

여러개의 Observable 시퀀스 방출을 하나의 Observable로 묶어준다. 개인적으로 flatMap에서 각 item을 Observable 으로 바꿔주는 부분만 제외하고 하나의 Observable로 만드는 과정은 동일하다고 느꼈다.

```swift
let 강북 = Observable.from(["강북구", "성북구", "동대문구", "종로구"])
let 강남 = Observable.from(["강남구", "강동구", "영등포구", "양천구"])

Observable.of(강북, 강남)
    .merge()
    .subscribe(onNext: {
        print("서울특별시의 구:", $0)
    })
    .disposed(by: disposeBag)

// 서울특별시의 구: 강북구
// 서울특별시의 구: 성북구
// 서울특별시의 구: 강남구
// 서울특별시의 구: 동대문구
// 서울특별시의 구: 강동구
// 서울특별시의 구: 종로구
// 서울특별시의 구: 영등포구
// 서울특별시의 구: 양천구
```

![스크린샷 2022-07-21 오후 5.34.46.png](Combining%20Operator%20246cbfff5c6d4cfca44e94b3f939dae3/%25E1%2584%2589%25E1%2585%25B3%25E1%2584%258F%25E1%2585%25B3%25E1%2584%2585%25E1%2585%25B5%25E1%2586%25AB%25E1%2584%2589%25E1%2585%25A3%25E1%2586%25BA_2022-07-21_%25E1%2584%258B%25E1%2585%25A9%25E1%2584%2592%25E1%2585%25AE_5.34.46.png)

concat과 달리 순서가 보장되지 않는것을 확인 할 수 있다. maxConcurrent를 통해서 한번에 받는 Observable 시퀀스의 수를 결정해서 concat과 동일한 결과를 얻을 수도 있다.

## 5) combineLatest

> ****when an item is emitted by either of two Observables, combine the latest item emitted by each Observable via a specified function and emit items based on the results of this function****
> 

두 개의 Obesrvable에서 아이템이 방출될 때 각각 Observable의 최신 아이템을 combine해서 방출한다

말로만 하면 어려워보이니까 바로 예제를 확인해보자

```swift
let 성 = PublishSubject<String>()
let 이름 = PublishSubject<String>()

let 성명 = Observable.combineLatest(성, 이름) { 성, 이름 in
  성 + 이름
}

성명
  .subscribe(onNext: {
    print($0)
  })
  .disposed(by: disposeBag)

성.onNext("신")
이름.onNext("똘똘")
이름.onNext("영수")
이름.onNext("상원")
성.onNext("이")
성.onNext("유")
성.onNext("조")

// 신똘똘
// 신영수
// 신상원
// 이상원
// 유상원
// 조상원
```

![스크린샷 2022-07-21 오후 6.09.32.png](Combining%20Operator%20246cbfff5c6d4cfca44e94b3f939dae3/%25E1%2584%2589%25E1%2585%25B3%25E1%2584%258F%25E1%2585%25B3%25E1%2584%2585%25E1%2585%25B5%25E1%2586%25AB%25E1%2584%2589%25E1%2585%25A3%25E1%2586%25BA_2022-07-21_%25E1%2584%258B%25E1%2585%25A9%25E1%2584%2592%25E1%2585%25AE_6.09.32.png)

결과를 보면 어떤식으로 동작하는지 이해할 수 있다. 주의할 점은 두 Observable 시퀀스에서 이벤트를 발생시켜야 합쳐져서 이벤트가 발생한다.

에러가 발생하는 경우에는 어떨까?

```swift
// 위와 동일한 상황
성.onNext("신")
이름.onNext("똘똘")
이름.onNext("상원")
성.onNext("이")
이름.onError(CError.error)
성.onNext("유")
성.onNext("조")
```

![스크린샷 2022-07-21 오후 6.32.02.png](Combining%20Operator%20246cbfff5c6d4cfca44e94b3f939dae3/%25E1%2584%2589%25E1%2585%25B3%25E1%2584%258F%25E1%2585%25B3%25E1%2584%2585%25E1%2585%25B5%25E1%2586%25AB%25E1%2584%2589%25E1%2585%25A3%25E1%2586%25BA_2022-07-21_%25E1%2584%258B%25E1%2585%25A9%25E1%2584%2592%25E1%2585%25AE_6.32.02.png)

둘중 하나의 Observable 시퀀스에서 에러 이벤트를 방출하면 에러를 방출하면서 시퀀스가 종료된다.

## 6) zip

> ****combine the emissions of multiple Observables together via a specified function and emit single items for each combination based on the results of this function****
> 

설명만 읽어보면 combineLatest와 유사하다.

```swift
let 성 = PublishSubject<String>()
let 이름 = PublishSubject<String>()

Observable.zip(성, 이름) { $0 + $1 }
  .subscribe{
    print($0)
  }
  .disposed(by: disposeBag)

성.onNext("신")
이름.onNext("똘똘")
이름.onNext("영수")
이름.onNext("상원")
성.onNext("이")
성.onNext("유")
성.onNext("조")

// next(신똘똘)
// next(이영수)
// next(유상원)
```

combineLatest와 동일한 예제를 zip으로 바꿔서 결과를 확인해보자

![스크린샷 2022-07-21 오후 7.01.04.png](Combining%20Operator%20246cbfff5c6d4cfca44e94b3f939dae3/%25E1%2584%2589%25E1%2585%25B3%25E1%2584%258F%25E1%2585%25B3%25E1%2584%2585%25E1%2585%25B5%25E1%2586%25AB%25E1%2584%2589%25E1%2585%25A3%25E1%2586%25BA_2022-07-21_%25E1%2584%258B%25E1%2585%25A9%25E1%2584%2592%25E1%2585%25AE_7.01.04.png)

각 Observable들의 최신값들을 이용해서 Combine 하는 CombineLatest 와 달리 짝을 맞춰서 Combine 하는 것을 확인할 수 있다.(”조” 에 매칭되는 이벤트가 없어 combine 되지 않는 것을 확인할 수 있다.)  만약 2개의 Observable중 하나가 먼저 종료되면 zip을 통해 생성되는 Observable도 시퀀스가 종료된다.

## 7) withLatestFrom

> Merges two observable sequences into one observable sequence by combining each element from self with the latest element from the second source, if any.
> 

바로 예제를 통해서 combineLatest와 뭐가 다른지 확인해보자!

```swift
let 성 = PublishSubject<String>()
let 이름 = PublishSubject<String>()

성.withLatestFrom(이름) { $0 + $1 }
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)

성.onNext("신")
이름.onNext("똘똘")
이름.onNext("영수")
이름.onNext("상원")
성.onNext("이")
성.onNext("유")
성.onNext("조")

// 이상원
// 유상원
// 조상원
```

![스크린샷 2022-07-21 오후 9.14.34.png](Combining%20Operator%20246cbfff5c6d4cfca44e94b3f939dae3/%25E1%2584%2589%25E1%2585%25B3%25E1%2584%258F%25E1%2585%25B3%25E1%2584%2585%25E1%2585%25B5%25E1%2586%25AB%25E1%2584%2589%25E1%2585%25A3%25E1%2586%25BA_2022-07-21_%25E1%2584%258B%25E1%2585%25A9%25E1%2584%2592%25E1%2585%25AE_9.14.34.png)

withLatestFrom을 이용하면 기준이 되는 Observable 시퀀스가 이벤트를 방출하는 시점에 withLatestFrom 에 들어오는 Observable 시퀀스의 최신값과 함께 combine 되어서 이벤트를 방출한다.

(”신” 이 방출되는 시점에 withLatestFrom 에 들어오는 Observable 시퀀스에 방출된 이벤트가 없기 때문에 무시 되는것을 확인 할 수 있다.)