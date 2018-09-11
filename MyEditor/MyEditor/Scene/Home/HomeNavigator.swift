//
//  HomeNavigator.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 8/30/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit

protocol HomeNavigatorType {
    func toHomeScreen()
    func toImageDetailScreen(photo: Photo)
    func toCollectionScreen(collection: Collection)
    func toSearchScreen()
}

struct HomeNavigator: HomeNavigatorType {
    unowned let navigationViewController: UINavigationController
    
    func toHomeScreen() {
        let vc = HomeViewController.instantiate()
        let model = HomeViewModel(navigator: self, useCase: HomeUseCase())
        vc.bindViewModel(to: model)
        self.navigationViewController.pushViewController(vc, animated: true)
    }
    
    func toCollectionScreen(collection: Collection) {
        let navigator = CollectionImagesNavigator(navigationViewController: navigationViewController)
        navigator.toCollectionImagesScreen(collection: collection)
    }
    
    func toImageDetailScreen(photo: Photo) {
        let navigator = DetailImageNavigator(navigationController: navigationViewController)
        navigator.toDetailScreen(photo: photo)
    }
    
    func toSearchScreen() {
        let navigator = SearchNavigator(navigationViewController: navigationViewController)
        navigator.toSearchScreen()
    }
}
