//
//  StackDownloadManager.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class StackDownloadManager {
    struct DownloadTask {
        let photo: Photo
        let progress: Double
    }
    
    static var shared = StackDownloadManager()
    var downloadTask: BehaviorRelay<[DownloadTask]> = BehaviorRelay<[DownloadTask]>(value: [DownloadTask]())
    
    private init() { }
    
}
