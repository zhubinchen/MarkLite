//
//  Constant.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

let donateProductID = "com.zhubch.MarkLite.Donate"

let imageUploadUrl = "http://up.imgapi.com/"

let uploadToken = "97ade20b4c5a86b625cf449f45f720d686a0154f:Mlg-545PK1Jp5vnxH0v1RP1_vc4=:eyJkZWFkbGluZSI6MTQ2NzEyODc0OCwiYWN0aW9uIjoiZ2V0IiwidWlkIjoiNTY3OTU0IiwiYWlkIjoiMTIyNjk3MSIsImZyb20iOiJmaWxlIn0="

let primaryColor = UIColor(hexString: "333333")!

let defaultFont = UIFont.font(ofSize: 16)
let windowWidth = UIApplication.shared.keyWindow?.w ?? 0
let windowHeight = UIApplication.shared.keyWindow?.h ?? 0

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""


let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""

let localPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + "/MarkLite"

let cloudPath: String? = {
    guard let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
        return nil
    }
    return ubiquityURL.path + "/MarkLite"
}()
