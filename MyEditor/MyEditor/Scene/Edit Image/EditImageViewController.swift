//
//  EditImageViewController.swift
//  MyEditor
//
//  Created by Do Hung on 9/6/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa
import Photos
import CoreImage

class EditImageViewController: UIViewController, BindableType {
    private struct Constant {
        static let widthCell = 100
        static let saveSuccess = "Save image to album MyEditor successfully!"
    }
    
    var viewModel: EditImageViewModel!
    private var state: EditType?
    private var lastestImage = PublishSubject<UIImage>()
    private var saveItem = UIBarButtonItem()
    private var doneItem = UIBarButtonItem()
    private var colorToDraw = UIColor.black
    private var strokeWidth: Float = 0
    private var lastPoint = CGPoint.zero
    private var fromPoint = CGPoint()
    private var listDrawImage = [UIImage]()
    private var indexImageDraw = 0
    private var contrastFilter = CIFilter(name: "CIColorControls")
    private var brightnessFilter = CIFilter(name: "CIColorControls")

    @IBOutlet private var contrastSlider: UISlider!
    @IBOutlet private var brightnessSlider: UISlider!
    @IBOutlet private var contrastView: UIView!
    @IBOutlet private var brightnessView: UIView!
    @IBOutlet private var viewContentImage: UIView!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var editView: EditView!
    @IBOutlet private var drawView: DrawView!
    @IBOutlet private var viewGuideCrop: UIView!
    @IBOutlet private var viewCrop: UIView!
    @IBOutlet private var bottom: NSLayoutConstraint!
    @IBOutlet private var trailing: NSLayoutConstraint!
    @IBOutlet private var leading: NSLayoutConstraint!
    @IBOutlet private var top: NSLayoutConstraint!
    @IBOutlet private var leadingImageView: NSLayoutConstraint!
    @IBOutlet private var topImageView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    private func configView() {
        editView.configCollectionView(viewController: self)
        drawView.delegate = self
        saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: nil)
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        viewCrop.isHidden = true
    }
    
    private func configFilter() {
<<<<<<< HEAD
        guard let image = imageView.image, let cgImage = image.cgImage else {
            return
        }
        let aCIImage = CIImage(cgImage: cgImage)
=======
        guard let image = imageView.image else {
            return
        }
        let cgImage = image.cgImage
        let aCIImage = CIImage(cgImage: cgImage!)
>>>>>>> brightness + contrast
        contrastFilter?.setValue(aCIImage, forKey: "inputImage")
        brightnessFilter?.setValue(aCIImage, forKey: "inputImage")
    }
    
    private func doneEdit() {
        if state == .crop {
            imageView.image = imageView.image?.resize(scaledTo: imageView.frame.size)?.crop(rect: viewCrop.frame)
        }
        configFilter()
        contrastSlider.value = 1
        brightnessSlider.value = 0
        state = nil
        listDrawImage = [UIImage]()
        updateConstaintImageView()
        resetConstraitViewCrop()
        viewCrop.isHidden = true
        navigationItem.rightBarButtonItem = saveItem
        guard let image = imageView.image else {
            return
        }
        lastestImage.onNext(image)
    }
    
    func resetConstraitViewCrop() {
        top.constant = 0
        leading.constant = 0
        trailing.constant = 0
        bottom.constant = 0
    }
    
    func updateConstaintImageView() {
        guard let image = imageView.image else {
            return
        }
        let ratioImage = Float(image.size.width) / Float(image.size.height)
        if ratioImage > 1 {
            leadingImageView.constant = 0
            topImageView.constant = (viewContentImage.frame.size.height - viewContentImage.frame.size.width / CGFloat(ratioImage)) / 2
        } else {
            topImageView.constant = 0
            leadingImageView.constant = (viewContentImage.frame.size.width - viewContentImage.frame.size.height * CGFloat(ratioImage)) / 2
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConstaintImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func bindViewModel() {
        let input = EditImageViewModel.Input(loadTrigger: Driver.just(()),
                                             clickSaveTrigger: saveItem.rx.tap.asDriver(),
                                             latestImage: lastestImage.asDriverOnErrorJustComplete(),
                                             clickDoneTrigger: doneItem.rx.tap.asDriver(),
                                             clickTypeEdit: editView.getCollection().rx.itemSelected.asDriver(),
                                             sliderDrawTrigger: drawView.getSlider().rx.value.asDriver(),
                                             clickUndoTrigger: drawView.getUndoButton().rx.tap.asDriver(),
                                             clickRedoTrigger: drawView.getRedoButton().rx.tap.asDriver(),
                                             sliderBrightnessTrigger: brightnessSlider.rx.value.asDriver(),
                                             sliderContrastTrigger: contrastSlider.rx.value.asDriver())
        let output = viewModel.transform(input)
        output.image
            .drive(imageView.rx.image)
            .disposed(by: rx.disposeBag)
        configFilter()
        output.clickedSave
            .drive(onNext: { result in
                if result {
                    self.makeToastWindow(title: Constant.saveSuccess)
                    self.tabBarController?.tabBar.isHidden = false
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
            .disposed(by: rx.disposeBag)
        output.clickedDone
            .drive(onNext: { [unowned self] _ in
                self.doneEdit()
                self.view.bringSubview(toFront: self.editView)
            })
            .disposed(by: rx.disposeBag)
        output.listEdit
            .drive(editView.getCollection().rx.items) { collectionView, index, element in
                let indexPath = IndexPath(row: index, section: 0)
                let cell: EditCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.setContentForCell(type: element)
                return cell
            }
            .disposed(by: rx.disposeBag)
        output.clickedTypeEdit
            .drive(onNext: { [unowned self] typeEdit in
                self.navigationItem.rightBarButtonItem = self.doneItem
                switch typeEdit {
                case .crop:
                    self.state = .crop
                    self.view.bringSubview(toFront: self.viewGuideCrop)
                    self.viewCrop.isHidden = false
                case .draw:
                    self.state = .draw
                    self.view.bringSubview(toFront: self.drawView)
                    self.listDrawImage = [UIImage]()
                    self.indexImageDraw = 0
                    guard let image = self.imageView.image else {
                        return
                    }
                    self.listDrawImage.append(image)
                case .brightness:
                    self.state = .brightness
                    self.view.bringSubview(toFront: self.brightnessView)
                case .contrast:
                    self.state = .contrast
                    self.view.bringSubview(toFront: self.contrastView)
                }
            })
            .disposed(by: rx.disposeBag)
        output.valueSliderDraw
            .drive(onNext: { [unowned self] value in
                self.strokeWidth = value
            })
            .disposed(by: rx.disposeBag)
        output.clickedUndo
            .drive(onNext: { [unowned self] _ in
                if self.indexImageDraw > 0 {
                    self.indexImageDraw -= 1
                    self.imageView.image = self.listDrawImage[self.indexImageDraw]
                }
            })
            .disposed(by: rx.disposeBag)
        output.clickedRedo
            .drive(onNext: { [unowned self] _ in
                if self.indexImageDraw < self.listDrawImage.count - 1 {
                    self.indexImageDraw += 1
                    self.imageView.image = self.listDrawImage[self.indexImageDraw]
                }
            })
            .disposed(by: rx.disposeBag)
        output.valueSliderBrightness.drive(onNext: { [unowned self] value in
                self.changeBrightness(value: value)
            })
            .disposed(by: rx.disposeBag)
        output.valueSliderContrast.drive(onNext: { [unowned self] value in
                self.changeContrast(value: value)
            })
            .disposed(by: rx.disposeBag)
        guard let image = imageView.image else {
            return
        }
        lastestImage.onNext(image)
    }
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: viewCrop)
        guard let viewPan = sender.view else {
            return
        }
        switch viewPan.tag {
        case 1:
            if leading.constant + translation.x >= 0 {
                leading.constant += translation.x
            }
            if top.constant + translation.y >= 0 {
                top.constant += translation.y
            }
        case 2:
            if trailing.constant - translation.x >= 0 {
                trailing.constant -= translation.x
            }
            if top.constant + translation.y >= 0 {
                top.constant += translation.y
            }
        case 3:
            if leading.constant + translation.x >= 0 {
                leading.constant += translation.x
            }
            if bottom.constant - translation.y >= 0 {
                bottom.constant -= translation.y
            }
        case 4:
            if trailing.constant - translation.x >= 0 {
                trailing.constant -= translation.x
            }
            if bottom.constant - translation.y >= 0 {
                bottom.constant -= translation.y
            }
        case 5:
            if top.constant + translation.y >= 0 {
                top.constant += translation.y
            }
        case 6:
            if leading.constant + translation.x >= 0 {
                leading.constant += translation.x
            }
        case 7:
            if trailing.constant - translation.x >= 0 {
                trailing.constant -= translation.x
            }
        case 8:
            if bottom.constant - translation.y >= 0 {
                bottom.constant -= translation.y
            }
        case 9:
            if leading.constant + translation.x >= 0 && trailing.constant - translation.x >= 0 {
                leading.constant += translation.x
                trailing.constant -= translation.x
            }
            if top.constant + translation.y >= 0 && bottom.constant - translation.y >= 0 {
                top.constant += translation.y
                bottom.constant -= translation.y
            }
        default:
            break
        }
        sender.setTranslation(CGPoint.zero, in: viewCrop)
    }
    
    //MARK: Edit_Draw
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint, width: Float) {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, true, 0.0)
        imageView.image?.draw(in: imageView.frame)
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(CGFloat(width))
        context?.setStrokeColor(colorToDraw.cgColor)
        context?.setBlendMode(CGBlendMode.normal)
        context?.strokePath()
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = 1
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let state = state, state == .draw {
            lastPoint = touch.preciseLocation(in: self.imageView)
        }
        if indexImageDraw < listDrawImage.count - 1 {
            for _ in indexImageDraw + 1 ... listDrawImage.count - 1 {
                listDrawImage.removeLast()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let state = state, state == .draw {
            let currentPoint = touch.preciseLocation(in: self.imageView)
            drawLine(fromPoint: lastPoint, toPoint: currentPoint, width: strokeWidth)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let image = imageView.image, let state = state, state == .draw {
            listDrawImage.append(image)
            indexImageDraw += 1
        }
    }
    
    //MARK: Edit Brightness + Contrast
    func changeBrightness(value: Float) {
        brightnessFilter?.setValue(NSNumber(value: value), forKey: "inputBrightness")
        guard let outputImage = brightnessFilter?.outputImage else {
            return
        }
        guard let cgImage = CIContext(options: nil).createCGImage(outputImage, from: outputImage.extent) else {
            return
        }
        let newImage = UIImage(cgImage: cgImage)
        imageView.image = newImage
    }
    
    func changeContrast(value: Float) {
        contrastFilter?.setValue(NSNumber(value: value), forKey: "inputContrast")
        guard let outputImage = contrastFilter?.outputImage else {
            return
        }
        guard let cgImage = CIContext(options: nil).createCGImage(outputImage, from: outputImage.extent) else {
            return
        }
        let newImage = UIImage(cgImage: cgImage)
        imageView.image = newImage
    }
}

extension EditImageViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(Constant.widthCell), height: collectionView.frame.size.height)
    }
}

extension EditImageViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.editImage
}

extension EditImageViewController: DrawViewDelegate {
    func getColor(color: UIColor) {
        colorToDraw = color
    }
}
