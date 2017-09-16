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
    
    static let configureFile = documentPath + "/Configure.plist"
    
    var newVersionAvaliable = false
    
    let editingFile: Variable<File?> = Variable(nil)
    let isLandscape = Variable(false)
    
    var currentVerion: String?
    var upgradeDate = Date()
    var alertDate = Date()
    var hasRate = false
    var isOldUser = false
    var isAutoClearEnabled = true
    let isAssistBarEnabled = Variable(true)
    let markdownStyle = Variable("GitHub2")
    let highlightStyle = Variable("github")
    let theme = Variable(Theme.white)
    
    override init() {
        super.init()
    }
    
    static let shared: Configure = {
        var configure = Configure()
        NSKeyedUnarchiver.setClass(Configure.self, forClassName: "Configure")
        if let old = NSKeyedUnarchiver.unarchiveObject(withFile: configureFile) as? Configure {
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
    
    func reset() {
        upgradeDate = Date()
        currentVerion = appVersion
        
        let stylePath = Bundle.main.url(forResource: "style", withExtension: "zip")
        let destStylePath = URL(fileURLWithPath: documentPath)
        try! Zip.unzipFile(stylePath!, destination: destStylePath, overwrite: true, password: nil, progress: nil)
        
        let samplesPath = Bundle.main.url(forResource: "samples", withExtension: "zip")
        let destSamplesPath = URL(fileURLWithPath: localPath)
        try! Zip.unzipFile(samplesPath!, destination: destSamplesPath, overwrite: true, password: nil, progress: nil)
        try? FileManager.default.moveItem(atPath: localPath + "/samples/" + /"Instructions", toPath: localPath + "/" + /"Instructions")
        try? FileManager.default.removeItem(atPath: localPath + "/samples")
        try? FileManager.default.createDirectory(atPath: draftPath, withIntermediateDirectories: true, attributes: nil)
        save()
    }
    
    func upgrade() {
        reset()

        currentVerion = appVersion
        isOldUser = true
        upgradeDate = Date()
        save()
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: Configure.configureFile)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(currentVerion, forKey: "currentVersion")
        aCoder.encode(isOldUser, forKey: "isOldUser")
        aCoder.encode(hasRate, forKey: "hasRate")
        aCoder.encode(isAutoClearEnabled, forKey: "isAutoClearEnabled")
        aCoder.encode(isAssistBarEnabled.value, forKey: "isAssistBarEnabled")
        aCoder.encode(markdownStyle.value, forKey: "markdownStyle")
        aCoder.encode(highlightStyle.value, forKey: "highlightStyle")
        aCoder.encode(theme.value.rawValue, forKey: "theme")
        aCoder.encode(upgradeDate, forKey: "upgradeDate")
        aCoder.encode(alertDate, forKey: "alertDate")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        currentVerion = aDecoder.decodeObject(forKey: "currentVersion") as? String
        upgradeDate = aDecoder.decodeObject(forKey: "upgradeDate") as? Date ?? Date()
        alertDate = aDecoder.decodeObject(forKey: "alertDate") as? Date ?? Date()
        isOldUser = aDecoder.decodeBool(forKey: "isOldUser")
        hasRate = aDecoder.decodeBool(forKey: "hasRate")
        isAutoClearEnabled = aDecoder.decodeBool(forKey: "isAutoClearEnabled")
        isAssistBarEnabled.value = aDecoder.decodeBool(forKey: "isAssistBarEnabled")
        markdownStyle.value = aDecoder.decodeObject(forKey: "markdownStyle") as? String ?? "GitHub2"
        highlightStyle.value = aDecoder.decodeObject(forKey: "highlightStyle") as? String ?? "rainbow"
        theme.value = Theme(rawValue:aDecoder.decodeObject(forKey: "theme") as? String ?? "") ?? .white
    }
}
