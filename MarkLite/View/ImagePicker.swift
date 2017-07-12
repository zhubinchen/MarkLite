//
//  ImagePicker.swift
//  WePost
//
//  Created by zhubch on 2017/4/6.
//  Copyright © 2017年 happyiterating. All rights reserved.
//

import Foundation
import Photos
import Alamofire


class ImagePicker: NSObject {
    
    weak var vc: UIViewController?
    
    var pickCompletionHanlder: ((UIImage)->Void)?
    
    init(viewController: UIViewController, completionHanlder:((UIImage)->Void)?) {
        vc = viewController
        pickCompletionHanlder = completionHanlder
        super.init()
    }
    
    func pickImage() {
        vc?.showActionSheet(title: "选取照片", actionTitles: ["相册","拍照"]) { [unowned self] (index) in
            if index == 0 {
                self.pickFromLibray()
            } else if index == 1 {
                self.pickFromCamera()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismissVC(completion: nil)

        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        guard image != nil else {
            return
        }
        pickCompletionHanlder?(image!)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismissVC(completion: nil)
    }
    
    func pickFromLibray() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .denied:
            vc?.showAlert(title: "无法打开照片，因为你没有允许微篇访问照片", message: "打开 设置->微篇 开启权限", actionTitles: ["取消","去设置"]) { (index) in
                if index == 1 {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ [unowned self] (status) in
                if status == .authorized {
                    self.showImagePickerFor(sourceType: .photoLibrary)
                }
            })
        case .authorized:
            showImagePickerFor(sourceType: .photoLibrary)
        default:
            showImagePickerFor(sourceType: .photoLibrary)
        }
    }
    
    func pickFromCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus {
        case .denied:
            vc?.showAlert(title: "无法打开相机，因为你没有允许微篇访问相机", message: "打开 设置->微篇 开启权限", actionTitles: ["取消","去设置"]) { (index) in
                if index == 1 {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ [unowned self] (status) in
                if status == .authorized {
                    self.showImagePickerFor(sourceType: .camera)
                }
            })
        case .authorized:
            showImagePickerFor(sourceType: .camera)
        default:
            showImagePickerFor(sourceType: .camera)
        }
    }
    
    func showImagePickerFor(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerVc = UIImagePickerController()
        imagePickerVc.modalPresentationStyle = sourceType == .camera ? .fullScreen : .popover
        imagePickerVc.sourceType = sourceType
        imagePickerVc.delegate = self
        imagePickerVc.allowsEditing = true
        vc?.presentVC(imagePickerVc)
    }
}

extension ImagePicker: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
}

