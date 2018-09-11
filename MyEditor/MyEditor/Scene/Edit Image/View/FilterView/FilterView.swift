//
//  FilterView.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit
import Reusable

class FilterView: UIView, NibOwnerLoadable {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNibContent()
    }
    
    func getCollectionView() -> UICollectionView {
        return collectionView
    }
    
    func configCollectionView(viewController: UIViewController) {
        collectionView.delegate = viewController as? UICollectionViewDelegate
        collectionView.register(cellType: FilterCell.self)
        collectionView.allowsMultipleSelection = false
    }
}
