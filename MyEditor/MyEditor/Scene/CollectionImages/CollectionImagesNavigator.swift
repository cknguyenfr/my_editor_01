//
//  CollectionImageNavigator.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/5/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit

protocol CollectionImagesNavigatorType {
    func toHomeScreen()
    func toImageDetailScreen()
    func toCollectionImagesScreen(collection: Collection)
    func toCollectionImageWith(searchKey: String)
}

struct CollectionImagesNavigator: CollectionImagesNavigatorType {
    unowned let navigationViewController: UINavigationController
    
    func toCollectionImagesScreen(collection: Collection) {
        let vc = CollectionImageViewController.instantiate()
        let model = CollectionImagesViewModel(navigator: self, useCase: CollectionImagesUseCase(), collection: collection, searchKey: "")
        vc.bindViewModel(to: model)
        self.navigationViewController.pushViewController(vc, animated: true)
    }
    
    func toCollectionImageWith(searchKey: String) {
        let vc = CollectionImageViewController.instantiate()
        let model = CollectionImagesViewModel(navigator: self, useCase: CollectionImagesUseCase(), collection: Collection(), searchKey: searchKey)
        vc.bindViewModel(to: model)
        self.navigationViewController.pushViewController(vc, animated: true)
    }
    
    func toHomeScreen() {
        self.navigationViewController.popViewController(animated: true)
    }
    // TODO: - NEXT_TASK
    func toImageDetailScreen() {
        print("for next task")
    }
}
