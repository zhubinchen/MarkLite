//
//  Constant.swift
//  Markdown
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

let rateUrl = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1302563558&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"

let emailUrl = "mailto:cheng4741@gmail.com?subject=MarkDown%20Report&body="
let itunesSecret = "92384cb418e2477082456c8221f9cb10"
let imageUploadUrl = "https://sm.ms/api/upload"
let umengKey = "5d2594e20cafb28ba1000dbe"

let defaultFont = UIFont.font(ofSize: 16)

var windowWidth: CGFloat { return UIApplication.shared.keyWindow?.w ?? 0}
var windowHeight: CGFloat { return UIApplication.shared.keyWindow?.h ?? 0 }

let appID = "1302563558"
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
let premiumProductID = "com.zhubc.premium"

let isPad = UIDevice.current.userInterfaceIdiom == .pad
let isPhone = UIDevice.current.userInterfaceIdiom == .phone

let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
let supportPath =  NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first ?? ""

let configPath = supportPath
let stylePath = supportPath + "/Style"
let tempPath = supportPath + "/Temp"
let draftPath = supportPath + "/Draft"
