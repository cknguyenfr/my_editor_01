//
//  CollectionImagesUseCase.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/5/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import RxSwift

protocol CollectionImagesUseCaseType {
    func getPhotos(collection: Collection) -> Observable<PagingInfo<Photo>>
    func getPhotos(collection: Collection, page: Int) -> Observable<PagingInfo<Photo>>
    func getPhotosWithSearchKey(querry: String) -> Observable<PagingInfo<Photo>>
    func getPhotosWithSearchKey(querry: String, page: Int) -> Observable<PagingInfo<Photo>>
}

struct CollectionImagesUseCase: CollectionImagesUseCaseType {
    func getPhotos(collection: Collection) -> Observable<PagingInfo<Photo>> {
        let repository = CollectionRepository(api: APIService.share)
        return repository.getImagesInCollection(collection: collection)
            .map { photos in
                return PagingInfo(items: photos)
        }
    }
    
    func getPhotos(collection: Collection, page: Int) -> Observable<PagingInfo<Photo>> {
        let repository = CollectionRepository(api: APIService.share)
        return repository.getImagesInCollection(collection: collection, page: page)
            .map { photos in
                return PagingInfo(page: page, items: photos)
        }
    }
    
    func getPhotosWithSearchKey(querry: String) -> Observable<PagingInfo<Photo>> {
        let repository = ImageRepository(api: APIService.share)
        return repository.searchPhotos(querry: querry)
            .map { photos in
                return PagingInfo(items: photos)
            }
    }
    
    func getPhotosWithSearchKey(querry: String, page: Int) -> Observable<PagingInfo<Photo>> {
        let repository = ImageRepository(api: APIService.share)
        return repository.searchPhotos(querry: querry, page: page)
            .map { photos in
                return PagingInfo(page: page, items: photos)
            }
    }
}
