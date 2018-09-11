//
//  DetailImageViewModel.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct DetailImageViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let downloadTrigger: Driver<Void>
    }
    
    struct Output {
        let resultLoad: Driver<Void>
    }
    
    let navigator: DetailImageNavigatorType
    let useCase: DetailImageUseCase
    let photo: Photo
    
    func transform(_ input: Input) -> Output {
        let resultLoad = input.loadTrigger.do(onNext: {
                self.useCase.getDetailImage(photo: self.photo)
            })
        
        return Output(
            resultLoad: resultLoad
        )
    }
}
