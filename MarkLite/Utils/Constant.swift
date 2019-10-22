//
//  Constant.swift
//  Markdown
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

let rateUrl = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1472328263&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

let emailUrl = "mailto:zhubingcheng.dev@gmail.com?subject=MarkDown%20Report&body=Tell%20me%20your%20device%20type%20and%20system%20version"
let weiboURL = "sinaweibo://userinfo?uid=5650591002"
let weiboWebPageURL = "https://weibo.com/u/5650591002"

let itunesSecret = "cf86d5cf3c0e440692140e5e80fd376e"
let imageUploadUrl = "https://sm.ms/api/upload"
let umengKey = "5d2594e20cafb28ba1000dbe"
let buglyId = "57bc8a7c74"

var windowWidth: CGFloat { return UIApplication.shared.keyWindow?.w ?? 0}
var windowHeight: CGFloat { return UIApplication.shared.keyWindow?.h ?? 0 }
var bottomInset: CGFloat {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    } else {
        return 0
    }
}

var security: Bool {
    let date = Date(fromString: "2019-10-22", format: "yyyy-MM-dd")!
    let now = Date()
    return now > date
}

let appID = "1472328263"
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
let premiumMonthlyProductID = "com.qinxiu.markdown.premium.monthly"
let premiumYearlyProductID = "com.qinxiu.markdown.premium.yearly"
let premiumForeverProductID = "com.qinxiu.markdown.premium.forever"

let isPad = UIDevice.current.userInterfaceIdiom == .pad
let isPhone = UIDevice.current.userInterfaceIdiom == .phone

let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
let supportPath =  NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first ?? ""

let configPath = supportPath
let resourcesPath = supportPath + "/Resources"
let tempPath = supportPath + "/Temp"
let inboxPath = supportPath + "/Inbox"
let locationPath = supportPath + "/Location"

let cloudPath: String = {
    guard let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
        return ""
    }
    return ubiquityURL.path
}()
