//
//  DetailImageUseCase.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxSwift
import Photos

protocol DetailImageUseCaseType {
    func getDetailImage(photo: Photo) -> Observable<Photo>
    func downloadImage(photo: Photo) -> Observable<Double>
    func saveImage(image: UIImage) -> Observable<Bool>
}

struct DetailImageUseCase: DetailImageUseCaseType {
    private struct Constant {
        static let albumName = "MyEditor"
    }
    
    func getDetailImage(photo: Photo) -> Observable<Photo> {
        let repository = ImageRepository(api: APIService.share)
        return repository.getDetailImage(photo: photo)
            . map { $0 }
    }
    
    func downloadImage(photo: Photo) -> Observable<Double> {
        return DownloadService.share.downloadPhoto(photo: photo)
    }
    
    func saveImage(image: UIImage) -> Observable<Bool> {
        return PHPhotoLibrary.shared()
            .findAlbum(albumName: Constant.albumName)
            .flatMapLatest { collection in
                return PHPhotoLibrary.shared().saveImage(image: image, album: collection)
        }
    }
}
