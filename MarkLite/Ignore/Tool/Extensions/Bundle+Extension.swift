//
//  Extension.swift
//  WeiBo
//
//  Created by 夜猫子 on 2017/4/5.
//  Copyright © 2017年 夜猫子. All rights reserved.
//


import UIKit

let versionKey = "versionKey"

// MARK: - 取到版本,并与上次比较
extension Bundle {
    
    var isNewFeature: Bool {

        let newVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

        let oldVersion = UserDefaults.standard.value(forKey: versionKey) as? String

        if oldVersion == nil || oldVersion! != newVersion {
            //将新版本存起来
            UserDefaults.standard.setValue(newVersion, forKey: versionKey)
            
            return true
        }
        
        return false
    }

}
