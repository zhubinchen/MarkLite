//
//  Constant.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

let rateUrl = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

let emailUrl = "mailto:cheng4741@gmail.com?subject=MarkLite%20Report&body="

let donateProductID = "com.zhubch.MarkLite.Donate"

let imageUploadUrl = "https://sm.ms/api/upload"

let defaultFont = UIFont.font(ofSize: 16)

var windowWidth: CGFloat { return UIApplication.shared.keyWindow?.w ?? 0}
var windowHeight: CGFloat { return UIApplication.shared.keyWindow?.h ?? 0 }

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

let isPad = UIDevice.current.userInterfaceIdiom == .pad
let isPhone = UIDevice.current.userInterfaceIdiom == .phone

let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""

let localPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + "/MarkLite"

let cloudPath: String? = {
    guard let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
        return nil
    }
    return ubiquityURL.path + "/MarkLite"
}()
