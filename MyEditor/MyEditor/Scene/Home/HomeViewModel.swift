//
//  HomeViewModel.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 8/29/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import RxSwift
import RxCocoa

struct HomeViewModel: ViewModelType {
    struct Input {
        let loadTrigger: Driver<Void>
        let randomImageTrigger: Driver<Void>
        let loadCollectionTrigger: Driver<Void>
        let reloadTableViewTrigger: Driver<Void>
        let loadMoreTableViewTrigger: Driver<Void>
        let reloadCollectionViewTrigger: Driver<Void>
        let loadMoreCollectionViewTrigger: Driver<Void>
        let selectTableViewTrigger: Driver<IndexPath>
        let selectCollectionViewTrigger: Driver<IndexPath>
        let toSearchViewTrigger: Driver<Void>
    }
    
    struct Output {
        let errorTableView: Driver<Error>
        let errorCollectionView: Driver<Error>
        let loadingTableView: Driver<Bool>
        let loadingCollectionView: Driver<Bool>
        let refreshing: Driver<Bool>
        let refreshingCollectionView: Driver<Bool>
        let loadingMoreTableView: Driver<Bool>
        let loadingMoreCollectionView: Driver<Bool>
        let fetchItemsTableView: Driver<Void>
        let fetchItemsCollectionView: Driver<Void>
        let randomPhoto: Driver<String>
        let photos: Driver<[Photo]>
        let collections: Driver<[Collection]>
        let isEmptyPhotoData: Driver<Bool>
        let isEmptyCollectionData: Driver<Bool>
        let selectedCollection: Driver<Void>
        let selectedPhoto: Driver<Void>
        let toSearchResult: Driver<Void>
    }
    
    let navigator: HomeNavigatorType
    let useCase: HomeUseCase
    
    func transform(_ input: Input) -> Output {
        let loadMoreOutputTableView = setupLoadMorePaging(loadTrigger: input.loadTrigger,
                                                          getItems: useCase.getPhotos,
                                                          refreshTrigger: input.reloadTableViewTrigger,
                                                          refreshItems: useCase.getPhotos,
                                                          loadMoreTrigger: input.loadMoreTableViewTrigger,
                                                          loadMoreItems: useCase.getPhotos)
        let loadMoreOutputCollectionView = setupLoadMorePaging(loadTrigger: input.loadCollectionTrigger,
                                                          getItems: useCase.getCollections,
                                                          refreshTrigger: input.reloadCollectionViewTrigger,
                                                          refreshItems: useCase.getCollections,
                                                          loadMoreTrigger: input.loadMoreCollectionViewTrigger,
                                                          loadMoreItems: useCase.getCollections)
        let (pageTable, fetchItemsTable, loadErrorTable, loadingTable, refreshingTable, loadingMoreTable) = loadMoreOutputTableView
        let (pageCollection, fetchItemsCollection, loadErrorCollection, loadingCollection, refreshingCollection, loadingMoreCollection) = loadMoreOutputCollectionView
        let photos = pageTable.map { $0.items }.asDriverOnErrorJustComplete()
        let collections = pageCollection.map { $0.items }.asDriverOnErrorJustComplete()
        let isEmptyPhotos = Driver.combineLatest(photos, loadingTable)
            .filter { !$0.1 }
            .map { $0.0.isEmpty }
        let isEmptyCollections = Driver.combineLatest(collections, loadingCollection)
            .filter { !$0.1 }
            .map { $0.0.isEmpty }
        let selectedCollection = input.selectCollectionViewTrigger
            .withLatestFrom(collections) { indexPath, collections in
                return collections[indexPath.row]
            }
            .do(onNext: { collection in
                self.navigator.toCollectionScreen(collection: collection)
            })
            .mapToVoid()
        let selectedPhoto = input.selectTableViewTrigger
            .withLatestFrom(photos) { indexPath, photos in
                return photos[indexPath.row]
            }.do(onNext: { photo in
                self.navigator.toImageDetailScreen(photo: photo)
//                print(photo)
            })
            .mapToVoid()
        let randomPhoto = input.randomImageTrigger
            .flatMapLatest { _ in
            self.useCase.getRandomPhoto()
                .trackError(ErrorTracker())
                .asDriverOnErrorJustComplete()
            }
            .map { photo in
                return photo.urls.regular
            }
        let toSearchResult = input.toSearchViewTrigger.do(onNext: { _ in
                self.navigator.toSearchScreen()
            })
        
        return Output(
            errorTableView: loadErrorTable,
            errorCollectionView: loadErrorCollection,
            loadingTableView: loadingTable,
            loadingCollectionView: loadingCollection,
            refreshing: refreshingTable,
            refreshingCollectionView: refreshingCollection,
            loadingMoreTableView: loadingMoreTable,
            loadingMoreCollectionView: loadingMoreCollection,
            fetchItemsTableView: fetchItemsTable,
            fetchItemsCollectionView: fetchItemsCollection,
            randomPhoto: randomPhoto,
            photos: photos,
            collections: collections,
            isEmptyPhotoData: isEmptyPhotos,
            isEmptyCollectionData: isEmptyCollections,
            selectedCollection: selectedCollection,
            selectedPhoto: selectedPhoto,
            toSearchResult: toSearchResult
        )
    }
}
