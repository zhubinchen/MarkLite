//
//  File.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/20.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions

enum FileType {
    case text
    case folder
    case other
}

fileprivate let fileManager = FileManager.default

class File {
    private(set) var name: String
    private(set) var extention: String
    private(set) var type: FileType
    private(set) var path: String
    private(set) var modifyDate: Date?
    private(set) var size: Int?
    
    fileprivate weak var parent: File?
    
    lazy var children: [File] {
        if _children == nil {
            _children = [File]()
        }
        return _children!
    }
    var isTemp = false
    var isSelected = false


    
    fileprivate var _children: [File]?
    
    init(path:String) {
        self.path = path
        self.name = path.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
        self.extention = path.components(separatedBy: ".").last ?? ""
        if extention == ".md" {
            self.type = .text
        } else {
            self.type = .folder
        }
    }
}

extension File {
    func createFile(name: String,type: FileType) -> File?{
        return nil
    }
}
