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

class Configure: NSObject, NSCoding {
    let currentFile: Variable<File?> = Variable(nil)
    var currentVerion: String?
    
    override init() {
        super.init()
    }
    
    static let shared: Configure = {
        let path = documentPath + "/Configure.plist"
        var configure = Configure()
        NSKeyedUnarchiver.setClass(Configure.self, forClassName: "Configure")
        if let old = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Configure {
            configure = old
            if appVersion != configure.currentVerion {
                configure.upgrade()
            }
        } else {
            configure.reset()
        }

        return configure
    }()
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(currentVerion, forKey: "currentVersion")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        currentVerion = aDecoder.decodeObject(forKey: "currentVersion") as? String
    }
    
    func reset() {
        
    }
    
    func upgrade() {
        currentVerion = appVersion
    }
}
