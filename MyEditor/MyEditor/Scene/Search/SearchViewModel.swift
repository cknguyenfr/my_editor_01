//
//  SearchViewModel.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/6/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxGesture

struct SearchViewModel: ViewModelType {
    fileprivate struct ConstantData {
        static let maxHistoryDisplay = 8
    }
    
    struct Input {
        let loadTrigger: Driver<Void>
        let searchTrigger: Driver<Void>
        let selectTrigger: Driver<IndexPath>
        let keywordTrigger: Driver<String>
        let cancelTrigger: Driver<Void>
    }
    
    struct Output {
        let sectionedSuggest: Driver<[SuggestSection]>
        let fetchData: Driver<Void>
        let loadResult: Driver<Void>
        let cancelTriggerResult: Driver<Void>
    }
    
    let navigator: SearchNavigatorType
    let useCase: SearchUseCase
    //arrTrending is a constant array
    let arrTrending = ["krishna", "girls", "4k wallpaper", "mehndi", "fall"]
    struct SuggestSection {
        let header: String
        let productList: [String]
    }
    
    func transform(_ input: Input) -> Output {
        let arrHistory = BehaviorRelay<[String]>(value: useCase.readHistory())
        let loadResult = input.loadTrigger.withLatestFrom(arrHistory.asDriver()) { _, histories in
                arrHistory.accept(histories)
            }
        let toCollectionResult = input.searchTrigger.withLatestFrom(input.keywordTrigger) { _, keyword -> String in
                self.navigator.toCollectionImagesScreen(collection: Collection())
                return keyword
            }
        let fetchData = toCollectionResult.withLatestFrom(arrHistory.asDriver()) { searchKey, histories in
                var latestArray = histories
                latestArray.insert(searchKey, at: 0)
                if latestArray.count >= ConstantData.maxHistoryDisplay {
                    latestArray.remove(at: ConstantData.maxHistoryDisplay - 1)
                }
                self.useCase.saveHistory(histories: histories)
                arrHistory.accept(latestArray)
            }
        let sectioned = arrHistory
            .map { [
                    SuggestSection(header: "History", productList: $0),
                    SuggestSection(header: "Trending", productList: self.arrTrending)
                ] }
            .asDriverOnErrorJustComplete()
        let cancelResult = input.cancelTrigger.do(onNext: {
                self.navigator.toHomeScreen()
            })
        return Output(
            sectionedSuggest: sectioned,
            fetchData: fetchData,
            loadResult: loadResult,
            cancelTriggerResult: cancelResult
        )
    }
}
