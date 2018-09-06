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
    func toImageDetailScreen()
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
    
    // TODO: - NEXT_TASK
    func toImageDetailScreen() {
        print("for next task")
    }
    
    func toSearchScreen() {
        print("for next task")
    }
}
