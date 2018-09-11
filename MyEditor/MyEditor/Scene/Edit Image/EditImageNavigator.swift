//
//  EditImageNavigator.swift
//  MyEditor
//
//  Created by Do Hung on 9/6/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import UIKit

protocol EditImageNavigatorType {
    func toEditImage(image: UIImage)
}

struct EditImageNavigator: EditImageNavigatorType {
    unowned let navigationController: UINavigationController
    
    func toEditImage(image: UIImage) {
        let editImageViewController = EditImageViewController.instantiate()
        let editImageViewModel = EditImageViewModel(originalImage: image, useCase: EditImageUseCase())
        editImageViewController.bindViewModel(to: editImageViewModel)
        navigationController.pushViewController(editImageViewController, animated: true)
    }
}
