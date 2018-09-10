//
//  SearchUseCase.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/6/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol SearchUseCaseType {
    func readHistory() -> [String]
    func saveHistory(histories: [String])
    func checkHistoryExist(histories: [String], keyword: String) -> Int
    func saveHistoryAndUpdate(histories: [String], searchKey: String, relay: BehaviorRelay<[String]>, maxHistoryCount: Int)
}

struct SearchUseCase: SearchUseCaseType {
    func readHistory() -> [String] {
        return readHistorySearch()
    }
    
    func saveHistory(histories: [String]) {
        return saveHistorySearch(histories: histories)
    }
    
    func checkHistoryExist(histories: [String], keyword: String) -> Int {
        return checkHistoryArray(histories: histories, keyword: keyword)
    }
    
    func saveHistoryAndUpdate(histories: [String], searchKey: String, relay: BehaviorRelay<[String]>, maxHistoryCount: Int) {
        var latestArray = histories
        let index = checkHistoryExist(histories: histories, keyword: searchKey)
        if index == -1 {
            if latestArray.count >= maxHistoryCount {
                latestArray.remove(at: maxHistoryCount - 1)
            }
        } else {
            latestArray.remove(at: index)
        }
        latestArray.insert(searchKey, at: 0)
        saveHistory(histories: latestArray)
        relay.accept(latestArray)
    }
}
