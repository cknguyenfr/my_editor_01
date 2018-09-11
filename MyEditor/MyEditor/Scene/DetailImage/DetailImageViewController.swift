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

class DetailImageViewController: UIViewController, BindableType {
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension DetailImageViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.detail
}
