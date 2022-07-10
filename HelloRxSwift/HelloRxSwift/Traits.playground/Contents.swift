import Foundation
import RxSwift

let disposeBag = DisposeBag()

enum TraitsError: Error {
  case single
  case maybe
  case completable
}

print("-------Single1---------")
Single<String>.just("💀") // Observable과 달리 onNext, onComplete (X)
  .subscribe(
    onSuccess: {
      print($0)
    },
    onFailure: {
      print("Error: \($0)")
    },
    onDisposed: {
      print("disposed")
    }
  )
  .disposed(by: disposeBag)

print("-------Single2---------")
Observable<String>
  .create { observer -> Disposable in
    observer.onError(TraitsError.single)
    return Disposables.create()
  }
  .asSingle()
  .subscribe(
    onSuccess: {
      print($0)
    },
    onFailure: {
      print("error: \($0)")
    },
    onDisposed: {
      print("disposed")
    }
  )
  .disposed(by: disposeBag)


print("-------Single3---------")
struct SomeJson: Decodable {
  let name: String
}

enum JsonError: Error {
case decodeError
}

let json1 = """
  {"name":"shin"}
  """

let json2 = """
  {"named":"shin"}
  """

func decode(json: String) -> Single<SomeJson> {
  Single<SomeJson>.create { observer -> Disposable in
    guard
      let data = json.data(using: .utf8),
      let json = try? JSONDecoder().decode(SomeJson.self, from: data)
    else {
      observer(.failure(JsonError.decodeError))
      return Disposables.create()
    }
    observer(.success(json))
    return Disposables.create()
  }
}

decode(json: json1)
  .subscribe {
    switch $0 {
    case .success(let json):
      print(json.name)
    case .failure(let error):
      print(error)
    }
  }
  .disposed(by: disposeBag)


decode(json: json2)
  .subscribe {
    switch $0 {
    case .success(let json):
      print(json.name)
    case .failure(let error):
      print(error)
    }
  }
  .disposed(by: disposeBag)


print("-------Maybe1---------")
Maybe<String>.just("💩") // onNext <-> onSuccess
  .subscribe(
    onSuccess: {
      print($0)
    },
    onError: {
      print($0)
    },
    onCompleted: {
      print("completed")
    },
    onDisposed: {
      print("disposed")
    }
  )
  .disposed(by: disposeBag)

print("-------Completable---------")
Completable.create { observer -> Disposable in
  observer(.error(TraitsError.completable))
  return Disposables.create()
}
.subscribe(
  onCompleted: {
    print("Completed")
  },
  onError: {
    print($0)
  },
  onDisposed: {
    print("disposed")
  }
)
.disposed(by: disposeBag)
