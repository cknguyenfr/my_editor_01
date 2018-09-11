//
//  ImageRepository.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 8/29/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import RxSwift

protocol ImageRepositoryType {
    func getNewPhotos(page: Int, perPage: Int) -> Observable<[Photo]>
    func getRandomPhoto() -> Observable<Photo>
    func searchPhotos(querry: String, page: Int, perPage: Int) -> Observable<[Photo]>
    func getDetailImage(photo: Photo) -> Observable<Photo>
}

final class ImageRepository: ImageRepositoryType {
    private var api: APIService
    
    required init(api: APIService) {
        self.api = api
    }
    
    func getNewPhotos(page: Int = 1, perPage: Int = 10) -> Observable<[Photo]> {
        let request = PhotoRequest(page: page, perPage: perPage)
        return api.request(input: request)
            .map { (output: PhotoResponse) -> [Photo] in
                return output.listPhotos
            }
    }
    
    func getRandomPhoto() -> Observable<Photo> {
        return api.request(input: RandomRequest()).map { (output: Photo) -> Photo in
            return output
        }
    }
    
    func searchPhotos(querry: String, page: Int = 1, perPage: Int = 10) -> Observable<[Photo]> {
        let request = SearchRequest(query: querry, page: page, perPage: perPage)
        return api.request(input: request)
            .map { (output: SearchResponse) -> [Photo] in
                return output.results
            }
    }
    
    func getDetailImage(photo: Photo) -> Observable<Photo> {
        let request = DetailImageRequest(photo: photo)
        return api.request(input: request)
            .map { (output: Photo) -> Photo in
                return output
            }
    }
}
