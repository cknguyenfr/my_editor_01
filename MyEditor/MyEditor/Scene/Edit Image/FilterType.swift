//
//  FilterType.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit

enum FilterType: String {
    case original
    case chroma
    case sobel
    case chrome
    case fade
    case instant
    case noir
    case process
    case tonal
    case transfer
    case sepiaTone
    
    var image: UIImage {
        return #imageLiteral(resourceName: "crop_view")
    }
    
    var title: String {
        return self.rawValue.capitalizingFirstLetter()
    }
    
    var key: String {
        switch self {
        case .original:
            return "Original"
        case .chroma:
            return "Chroma"
        case .sobel:
            return "Sobel"
        case .chrome:
            return "CIPhotoEffectChrome"
        case .fade:
            return "CIPhotoEffectFade"
        case .instant:
            return "CIPhotoEffectInstant"
        case .noir:
            return "CIPhotoEffectNoir"
        case .process:
            return "CIPhotoEffectProcess"
        case .tonal:
            return "CIPhotoEffectTonal"
        case .transfer:
            return "CIPhotoEffectTransfer"
        case .sepiaTone:
            return "CISepiaTone"
        }
    }
}
