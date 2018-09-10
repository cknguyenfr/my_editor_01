//
//  CollectionImageViewController.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/5/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Reusable

class CollectionImageViewController: UIViewController, BindableType {
    @IBOutlet weak var imageTableView: RefreshTableView!
    
    private let toHomeScreenSubject = PublishSubject<Void>()
    var viewModel: CollectionImagesViewModel!
    var arrRatio = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.toHomeScreenSubject.onNext(())
    }
    
    func configView() {
        imageTableView.rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
        imageTableView.do {
            $0.register(cellType: ImageTableCell.self)
        }
    }
    
    func bindViewModel() {
        let input = CollectionImagesViewModel.Input(
            loadTrigger: Driver.just(()),
            reloadTrigger: imageTableView.loadMoreTopTrigger,
            loadMoreTrigger: imageTableView.loadMoreBottomTrigger,
            selectPhotoTrigger: imageTableView.rx.itemSelected.asDriver(),
            toHomeScreenTrigger: toHomeScreenSubject.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input)
        output.photos
            .drive(imageTableView.rx.items) { tableView, index, photo in
                let indexPath = IndexPath(row: index, section: 0)
                let cell = tableView.dequeueReusableCell(for: indexPath) as ImageTableCell
                cell.fillData(url: photo.urls.regular, author: photo.id + "")
                return cell
            }
            .disposed(by: rx.disposeBag)
        output.loading
            .drive(rx.isLoading)
            .disposed(by: rx.disposeBag)
        output.loadingMore
            .drive(imageTableView.loadingMoreBottom)
            .disposed(by: rx.disposeBag)
        output.refreshing
            .drive(imageTableView.loadingMoreTop)
            .disposed(by: rx.disposeBag)
        output.error
            .drive(rx.error)
            .disposed(by: rx.disposeBag)
        output.selectedPhoto
            .drive()
            .disposed(by: rx.disposeBag)
        output.fetchItems
            .drive()
            .disposed(by: rx.disposeBag)
        output.isEmptyData
            .drive()
            .disposed(by: rx.disposeBag)
        output.collection
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        output.ratios.asObservable().subscribe(onNext: { ratios in
                self.arrRatio = ratios
            })
            .disposed(by: rx.disposeBag)
    }
}

extension CollectionImageViewController: UITableViewDelegate {
    private struct TableConstantData {
        static let defaultHeight = 300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < arrRatio.count {
            return tableView.bounds.size.width / arrRatio[indexPath.row]
        }
        return CGFloat(TableConstantData.defaultHeight)
    }
}

extension CollectionImageViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.collectionImages
}
