//
//  DetailImageNavigator.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit

protocol DetailImageNavigatorType {
    func toDetailScreen(photo: Photo)
    func backToPreviousScreen()
    func toEditScreen(image: UIImage)
}

struct DetailImageNavigator: DetailImageNavigatorType {
    unowned let navigationController: UINavigationController
    
    func toDetailScreen(photo: Photo) {
        let vc = DetailImageViewController.instantiate()
        let model = DetailImageViewModel(navigator: self, useCase: DetailImageUseCase(), photo: photo)
        vc.bindViewModel(to: model)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func backToPreviousScreen() {
        self.navigationController.popViewController(animated: true)
    }
    
    func toEditScreen(image: UIImage) {
        let navigator = EditImageNavigator(navigationController: navigationController)
        navigator.toEditImage(image: image)
    }
}
