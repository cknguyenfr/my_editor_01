//
//  FilterCell.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit
import Reusable

class FilterCell: UICollectionViewCell, NibReusable {
    @IBOutlet private weak var filterImageView: UIImageView!
    @IBOutlet private weak var filterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func fillData(image: UIImage, name: String) {
        filterImageView.image = image
        filterNameLabel.text = name
    }

}
