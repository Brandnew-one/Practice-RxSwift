# Transforming Operator

## 1) toArray

completed 된 시점까지 데이터를 Single<Array Type>로 바꿔서 방출한다.

```swift
Observable.of("1", "2", "3")
  .toArray() // Single로 바뀜
  .subscribe(onSuccess: { // Single이기 때문에 onSuccess
    print($0)
  })
  .disposed(by: disposeBag)

// ["1", "2", "3"]
```

Traits를 공부할 때, Single에 대해서 공부했었는데 간단하게 복습해보면 

> A Single is a variation of Observable that, instead of emitting a series of elements, is always guaranteed to emit either *a single element* or *an error*.
> 

single element를 방출하고 completed되는 success 이벤트 또는 error 이벤트와 동일한 failure 이벤트 2개만 존재했다.

## 2) map

Swift 고차함수에서 사용하던 map과 굉장히 유사하다. 우리가 일반적으로 Swift에서 고차함수로 사용하던 map를 먼저 확인해보자

```swift
// container.map( f(x) )
let numbers: [Int] = [0, 1, 2, 3, 4]
var doubleNumbers = numbers.map { $0 * 2 } // [0, 2, 4, 6, 8]
```

map은 자신을 호출할 때 매개변수로 전달된 함수를 실행해서 그 결과를 다시 반환해주는 함수 정도로 설명할 수 있을 것 같다. 그럼 RxSwift에서 사용되는 map은 어떨까?

> ****transform the items emitted by an Observable by applying a function to each item****
> 

> The Map operator applies a function of your choosing to each item emitted by the source Observable, and returns an Observable that emits the results of these function applications.
> 

공식홈페이지 설명을 보면 Observable에 의해서 방출되는 item 각각에 function을 적용한다. 즉, 우리가 Sequence에서 사용하던 map과 동일한데 Observable이란 container에 적용한다고 생각하면 된다

```swift
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

// 2022-07-20
```

위의 예제코드를 보면, Date 타입의 Observable을 string 타입의 Observable로 변경하고 있다.

(Observable 자체를 변경하는게 아니라 Observable 시퀀스의 element를 변경한다?)

## 3) flatMap

map과 마찬가지로 우선 Swift에서 우리가 사용했던 flatMap을 먼저 확인해보자

```swift
let numbers = [1, 2, 3, 4]

let mapped = numbers.map { Array(repeating: $0, count: $0) }
print(mapped) // [ [1], [2, 2], [3, 3, 3], [4, 4, 4, 4] ]

let flatMapped = numbers.flatMap { Array(repeating: $0, count: $0) }
print(flatMapped) // [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
```

flatMap의 경우에는 n차원 배열의 경우 n-1 차원으로 반환한다. 위와 경우, [[ Int ]] → [Int] 로 반환하는 것을 확인 할 수 있다. Rx에서는 어떨까?

> ****transform the items emitted by an Observable into Observables, then flatten the emissions from those into a single Observable****
> 

Observable에서 방출되는 아이템들을 Observable들로 바꿔주고, 이를 하나의 Observable로 평명화 시켜준다.

<img width="746" alt="스크린샷 2022-07-20 오후 10 54 15" src="https://user-images.githubusercontent.com/88618825/180055556-5373eeed-4284-4b99-aa05-21d7bfc6f9d8.png">

```swift
let sequenceInt = Observable.of(1, 2, 3)
let sequenceString = Observable.of("A", "B", "C", "D")
sequenceInt
  .flatMap { (x: Int) -> Observable<String> in
    return sequenceString.map { "\(x)" + $0 }
  }
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)

// next(1A)
// next(1B)
// next(2A)
// next(1C)
// next(2B)
// next(3A)
// next(1D)
// next(2C)
// next(3B)
// next(2D)
// next(3C)
// next(3D)
// completed
```

결과가 왜 이렇게 출력되는지 이해 되시나요? 전 안되니까 그림으로 하나씩 뜯어 봅시다

<img width="693" alt="스크린샷 2022-07-21 오전 1 06 10" src="https://user-images.githubusercontent.com/88618825/180055562-14220fbd-e798-4fc3-a5c5-da731f3490e7.png">

1) 처음에는 위 그림과 같은 형태의 Observable Sequence 가 존재

<img width="950" alt="스크린샷 2022-07-21 오전 1 14 28" src="https://user-images.githubusercontent.com/88618825/180055569-ebb2451a-7017-4c0f-bb2b-a3440301260e.png">

2) map을 통해서 Int와 문자열을 합친 문자열 ObserVable들을 만든다.

<img width="934" alt="스크린샷 2022-07-21 오전 1 16 01" src="https://user-images.githubusercontent.com/88618825/180055576-d85b85f5-a9b5-4618-8cd2-07818295a882.png">

3) 그리고 flatMap을 통해 이를 하나의 Observable로 평탄화 시켜준다.

결국 우리가 subscribe 하는것은 3)의 결과 Observable Sequence이기 때문에 위의 결과처럼 출력되는 것을 알 수 있다. 

즉, 여러개의 Observable Sequence를 하나의 Observable Sequence로 만드는 것에 의미가 있는것 같다. 우리가 Swift에서 사용하던 flatMap과 연관지어서 생각해보면 [Observable Sequence] → Observable Sequence 로 만들어주는 점에서 유사하다

## 4) flatMapFirst

> Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
If element is received while there is some projected observable sequence being merged it will simply be ignored.
> 

공식문서를 찾지 못해서 소스코드의 설명으로 대신했다. 

첫번째 문단의 내용을 보면 이전 flatMap과 동일하게 Observable Sequence들을 하나의 Observable Sequence로 merge하는 부분은 동일하다. 하지만 Observable Sequence과 merge되고 있을 때 element가 recevied되면 무시된다라는 부분이 이전과 다르다.

```swift
let sequenceInt = Observable.of(1, 2, 3)
let sequenceString = Observable.of("A", "B", "C", "D")
sequenceInt
  .flatMapFirst { (x: Int) -> Observable<String> in
    return sequenceString.map { "\(x)" + $0 }
  }
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)

// next(1A)
// next(1B)
// next(1C)
// next(1D)
// completed
```

위의 결과가 나오는건 이전 그림으로 이해할 수 있다.

<img width="950" alt="스크린샷 2022-07-21 오전 1 14 28" src="https://user-images.githubusercontent.com/88618825/180055569-ebb2451a-7017-4c0f-bb2b-a3440301260e.png">

첫번째 Int를 통해 Observable Sequence가 생성되고 완료되기 전에 두번째와 세번째가 들어오기 때문에 무시된다. 그래서 위와 같은 결과가 출력되는 것을 알 수 있다.

```swift
let sequenceInt = Observable.of(1, 2, 3, 4, 5, 6)
let sequenceString = Observable.of("A", "B", "C", "D")
sequenceInt
  .flatMapFirst { (x: Int) -> Observable<String> in
    return sequenceString.map { "\(x)" + $0 }
  }
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)

// next(1A)
// next(1B)
// next(1C)
// next(1D)
// next(6A)
// next(6B)
// next(6C)
// next(6D)
// completed
```

정말 완료되고 난 이후에는 이벤트가 넘어오는지 확인 해보기 위해서 sequenceInt를 늘려서 테스트 해보면 정말로 그렇다는 걸 확인 할 수 있다.

<img width="861" alt="스크린샷 2022-07-21 오전 3 11 18" src="https://user-images.githubusercontent.com/88618825/180055590-f71a2d52-3336-46f4-8eac-1621aa864e29.png">

이전 그림은 데이터 흐름을 명확하게 하려고 일부러 조금씩 띄워서 배치했었는데 헷갈릴 수 있을 거 같아 정확하게 표현하면 위와 같다. (1B, 2A는 동시에 발생하는 것!) 위의 그림을 보면 왜 6부터 다시 Observable Sequence가 합쳐 질 수 있는지 이해할 수 있다.

## 5) flatMapLatest

> Projects each element of an observable sequence into a new sequence of observable sequences and then transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.
> 

flatMap과 기본적인 구조는 비슷하다. 하지만 새로운 시퀀스를 만드는 중에 새로운 아이템이 방출된다면 이전 스트림을 dispose 한다. 말로 설명하니까 되게 어려운데 그림으로 확인해보자

```swift
let sequenceInt = Observable.of(1, 2, 3)
let sequenceString = Observable.of("A", "B", "C", "D")
sequenceInt
  .flatMapLatest { (x: Int) -> Observable<String> in
    return sequenceString.map { "\(x)" + $0 }
  }
  .subscribe {
    print($0)
  }
  .disposed(by: disposeBag)

// next(1A)
// next(2A)
// next(3A)
// next(3B)
// next(3C)
// next(3D)
// completed
```

<img width="795" alt="스크린샷 2022-07-21 오전 3 18 12" src="https://user-images.githubusercontent.com/88618825/180055601-06ea49cc-3623-4b1a-a372-83a34eb4f007.png">

1) map을 통해서 위와 같은 Observable Sequence들이 생성된다

<img width="774" alt="스크린샷 2022-07-21 오전 3 20 03" src="https://user-images.githubusercontent.com/88618825/180055609-74f81d09-6f27-4b79-ac89-cfc80a7e9b24.png">

새로운 Observable 시퀀스가 방출하기 시작하는 시점에 이전의 Observable 시퀀스를 dispose 시키는 것을 알 수 있다. 이런식으로 하나의 Observable 시퀀스를 생성하는게 flatMapLatest 이다.

RxSwift 코드를 보면서 오늘 정리한 내용들을 정확하게 이해하지 못하고 두루뭉실하게 아는 느낌이였는데 그래도 좀 정리가 된것 같다. 그래도 다시 코드보면 헷갈릴것 같긴한데 좀 더 익숙해지면 정리 다시하자!
