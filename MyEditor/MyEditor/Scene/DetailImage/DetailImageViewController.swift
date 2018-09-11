//
//  DetailImageViewController.swift
//  MyEditor
//
//  Created by Can Khac Nguyen on 9/11/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit
import Reusable
import RxCocoa
import RxSwift
import UICircularProgressRing

class DetailImageViewController: UIViewController, BindableType {
    
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var circleProgressRing: UICircularProgressRing!
    @IBOutlet weak var editButton: UIButton!
    
    var viewModel: DetailImageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        tabBarController?.tabBar.isHidden = false
    }
    
    func configView() {
        circleProgressRing.do {
            $0.maxValue = 100
        }
        circleProgressRing.isHidden = true
    }
    
    func bindViewModel() {
        let imageBehavior = BehaviorRelay<UIImage>(value: UIImage())
        let downloadCompleteBehavior = BehaviorRelay<Bool>(value: false)
        let input = DetailImageViewModel.Input( downloadTrigger: downloadButton.rx.tap.asDriver(),
                                                editTrigger: editButton.rx.tap.asDriver(),
                                                imageTrigger: imageBehavior.asDriver(),
                                                downloadCompleteTrigger: downloadCompleteBehavior.asDriver())
        let output = viewModel.transform(input)
        output.photo
            .drive(onNext: { photo in
                self.displayImageView.setImageForUrl(urlString: photo.urls.regular)
                guard let image = self.displayImageView.image else {
                    fatalError()
                }
                imageBehavior.accept(image)
            })
            .disposed(by: rx.disposeBag)
        output.downloadProgress
            .drive(onNext: { [unowned self] value in
                self.downloadButton.isHidden = true
                self.circleProgressRing.isHidden = false
                self.circleProgressRing.startProgress(to: UICircularProgressRing.ProgressValue(value), duration: 0)
                if value >= 100 {
                    downloadCompleteBehavior.accept(true)
                }
            })
            .disposed(by: rx.disposeBag)
        output.toEditResult
            .drive()
            .disposed(by: rx.disposeBag)
        output.imageResult
            .drive()
            .disposed(by: rx.disposeBag)
        output.saveToLibraryResult
            .drive()
            .disposed(by: rx.disposeBag)
    }
}

extension DetailImageViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.detail
}
