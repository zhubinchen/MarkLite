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
    let root = File(path: localPath)
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
        } else {
            configure.reset()
        }

        return configure
    }()
    
    func checkVersion() {
        if appVersion != currentVerion {
            upgrade()
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(currentVerion, forKey: "currentVersion")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        currentVerion = aDecoder.decodeObject(forKey: "currentVersion") as? String
    }
    
    func reset() {
        currentVerion = appVersion
    }
    
    func upgrade() {
        currentVerion = appVersion
        let other = root.createFile(name: "其他", type: .folder)
        root.children.forEach { file in
            if file.type == .text {
                file.move(to: other!)
            } else {
                refactor(at: file)
            }
        }
    }
        
    func refactor(at parent: File) {
        parent.children.filter{$0.type == .folder}.forEach { (file) in
            refactor(at: file)
            if file.children.count > 0 {
                file.move(to: self.root)
            } else {
                file.trash()
            }
        }
    }
}
