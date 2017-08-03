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
    let currentFile: Variable<File?> = Variable(nil)
    let isLandscape = Variable(false)
    let root = File(path: localPath)
    let tempFolderPath = documentPath + "/temp"
    
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
    
    func setup() {
        try? FileManager.default.removeItem(atPath: tempFolderPath)
        try? FileManager.default.createDirectory(atPath: tempFolderPath, withIntermediateDirectories: true, attributes: nil)
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
        
        let stylePath = Bundle.main.url(forResource: "style", withExtension: "zip")
        let destStylePath = URL(fileURLWithPath: documentPath)
        try! Zip.unzipFile(stylePath!, destination: destStylePath, overwrite: true, password: nil, progress: nil)
        
        let samplesPath = Bundle.main.url(forResource: "samples", withExtension: "zip")
        let destSamplesPath = URL(fileURLWithPath: localPath)
        try! Zip.unzipFile(samplesPath!, destination: destSamplesPath, overwrite: true, password: nil, progress: nil)
        loadRoot()
    }
    
    
    func upgrade() {
        currentVerion = appVersion
        reset()
        loadRoot()
    }
    
    func loadRoot() {
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
