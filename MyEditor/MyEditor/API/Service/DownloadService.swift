//
//  DownloadService.swift
//  MyEditor
//
//  Created by Do Hung on 8/29/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxCocoa
import Kingfisher

class DownloadService: NSObject {
    private struct Constant {
        static let nameAlbum = "MyEditor"
    }
    
    static let share = DownloadService()
    
    func downloadPhoto(photo: Photo) -> Observable<Double> {
        return Observable.create { observer in
            guard let url = URL(string: photo.urls.full) else {
                observer.onError(BaseError.unexpectedError)
                return Disposables.create()
            }
            ImageDownloader.default.downloadImage(with: url, progressBlock: { (current, total) in
                observer.onNext(Double(current) * 100 / Double(total))
            })
            return Disposables.create()
        }
    }
}

