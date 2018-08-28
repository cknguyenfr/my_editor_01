//
//  ErrorTracker.swift
//  MyEditor
//
//  Created by Do Hung on 8/28/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ErrorTracker: SharedSequenceConvertibleType {
    typealias SharingStrategy = DriverSharingStrategy
    private let subject = PublishSubject<Error>()
    
    func asObservable() -> Observable<Error> {
        return subject.asObservable()
    }
    
    func asSharedSequence() -> SharedSequence<SharingStrategy, Error> {
        return subject.asObservable().asDriverOnErrorJustComplete()
    }
    
    func onError(_ error: Error) {
        subject.onNext(error)
    }
    
    func trackError<O: ObservableConvertibleType>(from source: O) -> Observable<O.E> {
        return source.asObservable().do(onError: onError)
    }
    
    deinit {
        subject.onCompleted()
    }
}

extension ObservableConvertibleType {
    func trackError(_ errorTracker: ErrorTracker) -> Observable<E> {
        return errorTracker.trackError(from: self)
    }
}
