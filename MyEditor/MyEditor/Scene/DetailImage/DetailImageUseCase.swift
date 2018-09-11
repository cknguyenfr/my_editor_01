//
//  DetailImageUseCase.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxSwift

protocol DetailImageUseCaseType {
    func getDetailImage(photo: Photo) -> Observable<Photo>
}

struct DetailImageUseCase: DetailImageUseCaseType {
    func getDetailImage(photo: Photo) -> Observable<Photo> {
        let repository = ImageRepository(api: APIService.share)
        return repository.getDetailImage(photo: photo)
            . map { $0 }
    }
}
