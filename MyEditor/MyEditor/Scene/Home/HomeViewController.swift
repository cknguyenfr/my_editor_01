//
//  HomeViewController.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 8/29/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit
import Reusable
import Then
import RxCocoa

class HomeViewController: UIViewController, BindableType {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var exploreCollectionView: LoadMoreCollectionView!
    @IBOutlet private weak var photosTableView: RefreshTableView!
    @IBOutlet private weak var topView: UIView!
    
    var viewModel: HomeViewModel!
    var arrPhotos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        self.dismissKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismissKeyboard()
    }
    
    func configView() {
        photosTableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
        photosTableView.do {
            $0.estimatedRowHeight = 100
            $0.rowHeight = UITableViewAutomaticDimension
            $0.register(cellType: ImageTableCell.self)
        }
        exploreCollectionView.do {
            $0.register(cellType: ImageCollectionCell.self)
        }
        exploreCollectionView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
        searchBar.do {
            $0.backgroundColor = .clear
        }
    }
    
    func bindViewModel() {
        let input = HomeViewModel.Input(
            loadTrigger: Driver.just(()),
            loadCollectionTrigger:  Driver.just(()),
            reloadTableViewTrigger: photosTableView.loadMoreTopTrigger,
            loadMoreTableViewTrigger: photosTableView.loadMoreBottomTrigger,
            reloadCollectionViewTrigger: exploreCollectionView.refreshTrigger,
            loadMoreCollectionViewTrigger: exploreCollectionView.loadMoreTrigger,
            selectTableViewTrigger: photosTableView.rx.itemSelected.asDriver(),
            selectCollectionViewTrigger: exploreCollectionView.rx.itemSelected.asDriver(),
            toSearchViewTrigger: searchBar.rx.textDidBeginEditing.asDriver()
        )
        
        let output = viewModel.transform(input)
        output.photos
            .drive(photosTableView.rx.items) { tableView, index, photo in
                let indexPath = IndexPath(row: index, section: 0)
                if indexPath.row >= self.arrPhotos.count {
                    self.arrPhotos.append(photo)
                } else {
                    self.arrPhotos[indexPath.row] = photo
                }
                let cell = tableView.dequeueReusableCell(for: indexPath) as ImageTableCell
                cell.fillData(url: photo.urls.regular, author: photo.id + "")
                return cell
            }
            .disposed(by: rx.disposeBag)
        output.collections
            .drive(exploreCollectionView.rx.items) { collectionView, index, collection in
                let indexPath = IndexPath(item: index, section: 0)
                let cell = collectionView.dequeueReusableCell(for: indexPath) as ImageCollectionCell
                cell.fillData(url: collection.coverPhoto.urls.regular, title: collection.title)
                return cell
            }
            .disposed(by: rx.disposeBag)
        output.errorTableView
            .drive(rx.error)
            .disposed(by: rx.disposeBag)
        output.errorCollectionView
            .drive(rx.error)
            .disposed(by: rx.disposeBag)
        output.isEmptyPhotoData
            .drive()
            .disposed(by: rx.disposeBag)
        output.isEmptyCollectionData
            .drive()
            .disposed(by: rx.disposeBag)
        output.fetchItemsTableView
            .drive()
            .disposed(by: rx.disposeBag)
        output.fetchItemsCollectionView
            .drive()
            .disposed(by: rx.disposeBag)
        output.loadingTableView
            .drive(rx.isLoading)
            .disposed(by: rx.disposeBag)
        output.loadingCollectionView
            .drive(rx.isLoading)
            .disposed(by: rx.disposeBag)
        output.refreshing
            .drive(photosTableView.loadingMoreTop)
            .disposed(by: rx.disposeBag)
        output.refreshingCollectionView
            .drive(exploreCollectionView.refreshing)
            .disposed(by: rx.disposeBag)
        output.loadingMoreTableView
            .drive(photosTableView.loadingMoreBottom)
            .disposed(by: rx.disposeBag)
        output.loadingMoreCollectionView
            .drive(exploreCollectionView.loadingMore)
            .disposed(by: rx.disposeBag)
        output.selectedPhoto
            .drive()
            .disposed(by: rx.disposeBag)
        output.selectedCollection
            .drive()
            .disposed(by: rx.disposeBag)
        output.toSearchResult
            .drive()
            .disposed(by: rx.disposeBag)
    }
}

extension HomeViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.home
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private struct CollectionConstantData {
        static let edgeInset = UIEdgeInsetsMake(0, 10, 0, 10)
        static let offsetOfItem = 20
        static let sectionSpacing = 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width - CGFloat(CollectionConstantData.offsetOfItem), height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return CollectionConstantData.edgeInset
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(CollectionConstantData.sectionSpacing)
    }
}

extension HomeViewController: UITableViewDelegate {
    private struct TableConstantData {
        static let defaultHeight = 300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.arrPhotos.count {
            let ratio = CGFloat(self.arrPhotos[indexPath.row].width) / CGFloat(self.arrPhotos[indexPath.row].height)
            return CGFloat(tableView.bounds.size.width) / ratio
        }
        return CGFloat(TableConstantData.defaultHeight)
    }
}
