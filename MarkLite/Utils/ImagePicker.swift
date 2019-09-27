//
//  ImagePicker.swift
//  WePost
//
//  Created by zhubch on 2017/4/6.
//  Copyright © 2017年 happyiterating. All rights reserved.
//

import Foundation
import Photos


class ImagePicker: NSObject {
    
    weak var vc: UIViewController?
    
    var pickCompletionHanlder: ((UIImage)->Void)?
    
    init(viewController: UIViewController, completionHanlder:((UIImage)->Void)?) {
        vc = viewController
        pickCompletionHanlder = completionHanlder
        super.init()
    }
    
    func pickImage(_ sender: UIView? = nil) {
        vc?.showActionSheet(sender: sender, title: /"PickImage", actionTitles: [/"Photo",/"Camera"]) { [unowned self] (index) in
            if index == 0 {
                self.pickFromLibray()
            } else if index == 1 {
                self.pickFromCamera()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismissVC(completion: nil)

        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
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
            vc?.showAlert(title: /"PhotoError", message: /"EnablePhotoTips", actionTitles: [/"Cancel",/"Settings"]) { (index) in
                if index == 1 {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ [unowned self] (status) in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.showImagePickerFor(sourceType: .photoLibrary)
                    }
                }
            })
        case .authorized:
            showImagePickerFor(sourceType: .photoLibrary)
        default:
            showImagePickerFor(sourceType: .photoLibrary)
        }
    }
    
    func pickFromCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .denied:
            vc?.showAlert(title: /"CameraError", message: /"EnableCameraTips", actionTitles: [/"Cancel",/"Settings"]) { (index) in
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
        imagePickerVc.modalPresentationStyle = .formSheet
        imagePickerVc.sourceType = sourceType
        imagePickerVc.delegate = self

        DispatchQueue.main.async {
            self.vc?.presentVC(imagePickerVc)
        }
    }
}

extension ImagePicker: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
}

