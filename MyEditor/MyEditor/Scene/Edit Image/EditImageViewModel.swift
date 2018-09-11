//
//  EditImageViewModel.swift
//  MyEditor
//
//  Created by Do Hung on 9/6/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

struct EditImageViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let clickSaveTrigger: Driver<Void>
        let latestImage: Driver<UIImage>
        let clickDoneTrigger: Driver<Void>
        let clickTypeEdit: Driver<IndexPath>
        let sliderDrawTrigger: Driver<Float>
        let clickUndoTrigger: Driver<Void>
        let clickRedoTrigger: Driver<Void>
        let sliderBrightnessTrigger: Driver<Float>
        let sliderContrastTrigger: Driver<Float>
        let clickFilterType: Driver<IndexPath>
    }
    
    struct Output {
        let image: Driver<UIImage>
        let clickedSave: Driver<Bool>
        let clickedDone: Driver<Void>
        let listEdit: Driver<[EditType]>
        let listFilter: Driver<[FilterData]>
        let clickedTypeEdit: Driver<EditType>
        let clickedFilterType: Driver<UIImage>
        let valueSliderDraw: Driver<Float>
        let clickedUndo: Driver<Void>
        let clickedRedo: Driver<Void>
        let valueSliderBrightness: Driver<Float>
        let valueSliderContrast: Driver<Float>
        let imageLoadResult: Driver<Void>
    }
    
    let originalImage: UIImage
    let useCase: EditImageUseCaseType
    struct FilterData {
        let title: String
        let image: UIImage
    }
    
    func transform(_ input: EditImageViewModel.Input) -> EditImageViewModel.Output {
        let editOptions = [EditType.crop, .draw, .brightness, .contrast]
        let filterOptions = [FilterType.original, .chroma, .sobel, .chrome, .fade, .instant, .noir, .process, .tonal, .transfer, .sepiaTone]
        let image = input.loadTrigger
            .map {  _ in self.originalImage }
        let clickedSave = input.clickSaveTrigger
            .withLatestFrom(input.latestImage) { _, image in
                return image
            }
            .flatMapLatest { image in
                self.useCase.saveImage(image: image)
                    .asDriverOnErrorJustComplete()
            }
        let clickedDone = input.clickDoneTrigger
        let listEdit = Driver.just(editOptions)
        let clickedTypeEdit = input.clickTypeEdit
            .map { indexPath in
            return editOptions[indexPath.row]
        }
        let valueSliderDraw = input.sliderDrawTrigger
        let clickedUndo = input.clickUndoTrigger
        let clickedRedo = input.clickRedoTrigger
        let valueSliderBrightness = input.sliderBrightnessTrigger
        let valueSliderContrast = input.sliderContrastTrigger
        let filterData = BehaviorRelay<[FilterData]>(value: [FilterData]())
        let imageLoadResult = input.loadTrigger.withLatestFrom(Driver.just(filterOptions)) { _, types in
            var datas = [FilterData]()
            for type in types {
                let img = self.useCase.filterImage(image: self.originalImage, with: type, isScale: true)
                let data = FilterData(title: type.title, image: img)
                datas.append(data)
            }
            filterData.accept(datas)
        }
        let clickedFilterType = input.clickFilterType.withLatestFrom(filterData.asDriver()) { indexPath, filters in
            self.useCase.filterImage(image: self.originalImage, with: filterOptions[indexPath.row], isScale: false)
        }
        
        return Output(
            image: image,
            clickedSave: clickedSave.asDriver(),
            clickedDone: clickedDone,
            listEdit: listEdit,
            listFilter: filterData.asDriver(),
            clickedTypeEdit: clickedTypeEdit,
            clickedFilterType: clickedFilterType,
            valueSliderDraw: valueSliderDraw,
            clickedUndo: clickedUndo,
            clickedRedo: clickedRedo,
            valueSliderBrightness: valueSliderBrightness,
            valueSliderContrast: valueSliderContrast,
            imageLoadResult: imageLoadResult
        )
    }
}
