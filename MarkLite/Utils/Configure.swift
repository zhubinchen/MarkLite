//
//  Configure.swift
//  MarkLite
//
//  Created by zhubch on 2017/7/1.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Zip

class Configure: NSObject, NSCoding {
    
    let editingFile: Variable<File?> = Variable(nil)
    let isLandscape = Variable(false)
    
    var currentVerion: String?
    var isVip = false
    var isOldUser = false
    var isAssistBarEnabled = Variable(true)
    var markdownStyle = Variable("GitHub2")
    var highlightStyle = Variable("rainbow")
    var theme = Variable(Theme.white)
    
    override init() {
        super.init()
    }
    
    static let shared: Configure = {
        let path = documentPath + "/Configure.plist"
        var configure = Configure()
        NSKeyedUnarchiver.setClass(Configure.self, forClassName: "Configure")
        if let old = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Configure {
            configure = old
        } else {
            configure.reset()
        }

        return configure
    }()
    
    func setup() {
        try? FileManager.default.removeItem(atPath: tempFolderPath)
        try? FileManager.default.createDirectory(atPath: tempFolderPath, withIntermediateDirectories: true, attributes: nil)
        if appVersion != currentVerion {
            upgrade()
        }
    }
    
    func checkVipAvailable(_ completion:((Bool)->Void)? = nil){
        IAP.validateReceipt(itunsSecretKey) { (statusCode, products, json) in
            defer {
                DispatchQueue.main.async {
                    completion?(self.isVip)
                }
            }
            guard let products = products else {
                self.isVip = false
                return
            }
            print("products: \(products)")
            let expiredDate1 = products[monthlyVIPProductID] ?? Date(timeIntervalSince1970: 0)
            let expiredDate2 = products[annualVIPProductID] ?? Date(timeIntervalSince1970: 0)
            let expiredDate = max(expiredDate1, expiredDate2)

            self.isVip = expiredDate.isFuture
        }
    }
    
    func reset() {
        currentVerion = appVersion
        
        let stylePath = Bundle.main.url(forResource: "style", withExtension: "zip")
        let destStylePath = URL(fileURLWithPath: documentPath)
        try! Zip.unzipFile(stylePath!, destination: destStylePath, overwrite: true, password: nil, progress: nil)
        
        let samplesPath = Bundle.main.url(forResource: "samples", withExtension: "zip")
        let destSamplesPath = URL(fileURLWithPath: localPath)
        try! Zip.unzipFile(samplesPath!, destination: destSamplesPath, overwrite: true, password: nil, progress: nil)
        
        try! FileManager.default.createDirectory(atPath: draftPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    func upgrade() {
        currentVerion = appVersion
        isOldUser = true
        reset()
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "CurrentUser")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(currentVerion, forKey: "currentVersion")
        aCoder.encode(isOldUser, forKey: "isOldUser")
        aCoder.encode(isVip, forKey: "isVip")
        aCoder.encode(isAssistBarEnabled.value, forKey: "isAssistBarEnabled")
        aCoder.encode(markdownStyle.value, forKey: "markdownStyle")
        aCoder.encode(highlightStyle.value, forKey: "highlightStyle")
        aCoder.encode(theme.value, forKey: "theme")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        currentVerion = aDecoder.decodeObject(forKey: "currentVersion") as? String
        isOldUser = aDecoder.decodeObject(forKey: "isOldUser") as? Bool ?? false
        isVip = aDecoder.decodeObject(forKey: "isVip") as? Bool ?? false
        isAssistBarEnabled.value = aDecoder.decodeObject(forKey: "isAssistBarEnabled") as? Bool ?? true
        markdownStyle.value = aDecoder.decodeObject(forKey: "markdownStyle") as? String ?? "GitHub2"
        highlightStyle.value = aDecoder.decodeObject(forKey: "highlightStyle") as? String ?? "rainbow"
        theme.value = aDecoder.decodeObject(forKey: "theme") as? Theme ?? .white
    }
}
