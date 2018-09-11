//
//  EditImageUseCase.swift
//  MyEditor
//
//  Created by Do Hung on 9/10/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Photos
import CoreImage

protocol EditImageUseCaseType {
    func saveImage(image: UIImage) -> Observable<Bool>
    func filterImage(image: UIImage, with option: FilterType, isScale: Bool) -> UIImage
}

struct EditImageUseCase: EditImageUseCaseType {
    private struct Constant {
        static let albumName = "MyEditor"
    }
    
    let ciContext = CIContext(options: nil)
    
    func saveImage(image: UIImage) -> Observable<Bool> {
        return PHPhotoLibrary.shared()
            .findAlbum(albumName: Constant.albumName)
            .flatMapLatest { collection in
                return PHPhotoLibrary.shared().saveImage(image: image, album: collection)
        }
    }
    
    func filterImage(image: UIImage, with option: FilterType, isScale: Bool) -> UIImage {
        //resize image first
        var imageFilter = image
        if isScale {
            let scale = image.size.width / 100
            let newSize = CGSize(width: 100, height: image.size.height / scale)
            if let newImage = image.resize(scaledTo: newSize) {
                imageFilter = newImage
            } else {
                imageFilter = image
            }
        }
        
        switch option {
        case .original:
                return imageFilter
            case .chroma:
                return filterWithChromaKeyEffect(image: imageFilter)
            case .sobel:
                return filterWithSobelEffect(image: imageFilter)
            default:
                return filterWithBuildInFilter(image: imageFilter, filterName: option.key)
        }
    }
    
    private func filterWithChromaKeyEffect(image: UIImage) -> UIImage {
        //set up filter
        let filter = ChromaKeyFilter()
        filter.inputImage = CIImage(image: image)
        //get output image
        
        guard let outputImage = filter.outputImage else {
            return image
        }
        return UIImage(ciImage: outputImage)
    }
    
    private func filterWithSobelEffect(image: UIImage) -> UIImage {
        //set up filter
        let filter = SobelFilter()
        filter.inputImage = CIImage(image: image)
        //get output image
        
        guard let outputImage = filter.outputImage else {
            return image
        }
        return UIImage(ciImage: outputImage)
    }
    
    private func filterWithBuildInFilter(image: UIImage, filterName: String) -> UIImage {
        let coreImage = CIImage(image: image)
        guard let filter = CIFilter(name: filterName) else {
            fatalError()
        }
        filter.setDefaults()
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let filteredImageData = filter.value(forKey: kCIOutputImageKey) as? CIImage,
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent) else {
            fatalError()
        }
        return UIImage(cgImage: filteredImageRef)
    }
}
