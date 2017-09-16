//
//  ImageSaver.swift
//  MarkLite
//
//  Created by zhubch on 2017/9/3.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import Photos

protocol ImageSaver: NSObjectProtocol {
    func saveImage(_ image: UIImage)
    var currentVC: UIViewController { get }
}

extension ImageSaver where Self: UIViewController {
    var currentVC: UIViewController {
        return self
    }
}

extension ImageSaver {
    func saveImage(_ image: UIImage) {
        
        let saveImageClosure: (UIImage) -> Void = { image in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { isSuccess, error in
                DispatchQueue.main.async {
                    if isSuccess {
                        self.currentVC.showAlert(title: /"SaveSuccessed")
                    } else {
                        self.currentVC.showAlert(title: /"SaveFailed")
                    }
                }
            })
        }
        
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .denied:
            currentVC.showAlert(title: /"PhotoError", message: /"EnablePhotoTips", actionTitles: [/"Cancel",/"Settings"]) { (index) in
                if index == 1 {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    saveImageClosure(image)
                }
            })
        case .authorized:
            saveImageClosure(image)
        default:
            saveImageClosure(image)
        }
    }
}
