//
//  Constant.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

let dropboxKey = "efmdoostf798xsr"
let dropboxSecret = "lqia8vqvxbk9a7o"
let dropboxToken = "U8P2_p2-VQAAAAAAAAAAD6CtjD75IjwamQSkEblPY4NqwJG4VEJZbxk9F877jtdm"

let rateUrl = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
let upgradeUrl = "itms-apps://itunes.apple.com/app/id1098107145"
let checkVersionUrl = "http://itunes.apple.com/lookup?id=1098107145"
let emailUrl = "mailto:cheng4741@gmail.com?subject=MarkLite%20Report&body="

let imageUploadUrl = "https://sm.ms/api/upload"

let defaultFont = UIFont.font(ofSize: 16)

var windowWidth: CGFloat { return UIApplication.shared.keyWindow?.w ?? 0}
var windowHeight: CGFloat { return UIApplication.shared.keyWindow?.h ?? 0 }

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

let isPad = UIDevice.current.userInterfaceIdiom == .pad
let isPhone = UIDevice.current.userInterfaceIdiom == .phone

let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""

let tempFolderPath = documentPath + "/temp"

let localPath = documentPath + "/MarkLite"

let draftPath = documentPath + "/Draft"

let iCloudPath: String = {
    guard let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
        return ""
    }
    return ubiquityURL.path
}()
