//
//  DetailImageNavigator.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit

protocol DetailImageNavigatorType {
    func toDetailScreen()
    func backToPreviousScreen()
    func toEditScreen()
}

struct DetailImageNavigator: DetailImageNavigatorType {
    unowned let navigationController: UINavigationController
    
    func toDetailScreen() {
        let vc = DetailImageViewController.instantiate()
        let model = DetailImageViewModel(navigator: self, useCase: DetailImageUseCase())
        vc.bindViewModel(to: model)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func backToPreviousScreen() {
        self.navigationController.popViewController(animated: true)
    }
    
    func toEditScreen() {
        //TODO: NEXT_TASK
    }
}
