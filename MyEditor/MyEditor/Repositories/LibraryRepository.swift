//
//  LibraryRepository.swift
//  MyEditor
//
//  Created by Do Hung on 8/31/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import RxSwift
import Photos

protocol LibraryRepositoryType {
    func getListAlbum() -> Observable<[Album]>
}

final class LibraryRepository: LibraryRepositoryType {
    private struct Constant {
        static let defaultSize = 100
    }
    
    func getListAlbum() -> Observable<[Album]> {
        return Observable.create { observer in
            var albums = [Album]()
            let fetchOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
            let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            let allAlbums = [topLevelUserCollections, smartAlbums]
            for i in 0 ..< allAlbums.count {
                let result = allAlbums[i]
                (result as AnyObject).enumerateObjects { (asset, index, stop) -> Void in
                    guard let album = asset as? PHAssetCollection else {
                        return
                    }
                    let options = PHFetchOptions()
                    options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                    let assets = PHAsset.fetchAssets(in: album, options: options)
                    guard let _ = assets.firstObject else {
                        return
                    }
                    PHImageManager.default()
                        .requestImage(for: assets[assets.count - 1],
                                      targetSize: CGSize(width: Constant.defaultSize, height: Constant.defaultSize),
                                      contentMode: PHImageContentMode.default,
                                      options: nil,
                                      resultHandler: { (result, info) in
                        guard let image = result else {
                            return
                        }
                        let newAlbum = Album(name: album.localizedTitle!, count: assets.count, collection:album, latestImage: image)
                        albums.append(newAlbum)
                    })
                }
            }
            observer.onNext(albums)
            return Disposables.create()
        }
    }
}
