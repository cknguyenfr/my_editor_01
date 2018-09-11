//
//  DetailImageViewModel.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct DetailImageViewModel: ViewModelType {
    struct Input {
        let downloadTrigger: Driver<Void>
        let editTrigger: Driver<Void>
        let imageTrigger: Driver<UIImage>
        let downloadCompleteTrigger: Driver<Bool>
    }
    
    struct Output {
        let photo: Driver<Photo>
        let downloadProgress: Driver<Double>
        let toEditResult: Driver<Void>
        let imageResult: Driver<Void>
        let saveToLibraryResult: Driver<Bool>
    }
    
    let navigator: DetailImageNavigatorType
    let useCase: DetailImageUseCase
    let photo: Photo
    
    func transform(_ input: Input) -> Output {
        let detailPhoto = self.useCase.getDetailImage(photo: self.photo).asDriverOnErrorJustComplete()
        let dowloadProgress = input.downloadTrigger
            .flatMapLatest { _ in
                self.useCase.downloadImage(photo: self.photo).asDriverOnErrorJustComplete()
            }
        let toEditResult = input.editTrigger
            .withLatestFrom(input.imageTrigger) { _, image in
                self.navigator.toEditScreen(image: image)
            }
        let saveResult = input.downloadCompleteTrigger
            .filter { $0 }
            .withLatestFrom(input.imageTrigger) { _, image in
                return image
            }
            .flatMapLatest { image in
                self.useCase.saveImage(image: image).asDriverOnErrorJustComplete()
            }
        
        return Output(
            photo: detailPhoto,
            downloadProgress: dowloadProgress,
            toEditResult: toEditResult,
            imageResult: input.imageTrigger.mapToVoid(),
            saveToLibraryResult: saveResult
        )
    }
}
