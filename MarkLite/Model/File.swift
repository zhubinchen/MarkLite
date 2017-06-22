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
    
    var extensionName: String {
        switch self {
        case .text:
            return ".md"
        default:
            return ""
        }
    }
}

fileprivate let fileManager = FileManager.default

class File {
    private(set) var name: String
    private(set) var extention: String
    private(set) var type: FileType
    private(set) var path: String
    private(set) var modifyDate: Date?
    private(set) var size: Int?
    
    var children: [File] {
        return _children
    }
    
    fileprivate weak var parent: File?
    fileprivate var _children: [File] = [File]()
    fileprivate var fullName: String {
        return name + extention
    }
    
    var isTemp = false
    var isSelected = false
    
    init(path:String) {
        print(path)
        self.path = path
        self.name = path.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
        self.extention = path.components(separatedBy: ".").last ?? ""
        if extention == ".md" {
            self.type = .text
        } else {
            self.type = .folder
        }
        guard let subPaths = try? fileManager.contentsOfDirectory(atPath: path) else {
            return
        }
        _children = subPaths.map{ File(path:self.path + "/" + $0,parent: self) }
    }
    
    convenience init(path: String, parent: File) {
        self.init(path: path)
        self.parent = parent
    }
    
    public static func ==(lhs: File, rhs: File) -> Bool {
        return lhs.path == rhs.path
    }
    
    @discardableResult
    func createFile(name: String,type: FileType) -> File?{
        let path = (self.path + "/" + name + type.extensionName).validPath
        if type == .text {
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
        } else {
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        let file = File(path: path, parent: self)
        _children.append(file)
        return file
    }
    
    @discardableResult
    func trash() -> Bool {
        try? fileManager.removeItem(atPath: self.path)
        
        guard let i = parent?._children.index(where: { (file) -> Bool in
            return file == self
        }) else { return false }
        parent?._children.remove(at: i)
        return true
    }
    
    @discardableResult
    func move(to newParent: File) -> Bool {
        let newPath = (newParent.path + "/" + fullName).validPath
        try? fileManager.moveItem(atPath: path, toPath: newPath)
        guard let i = parent?._children.index(where: { (file) -> Bool in
            return file == self
        }) else { return false }
        parent?._children.remove(at: i)
        newParent._children.append(self)
        path = newPath
        return true
    }
    
    @discardableResult
    func rename(to newName: String) -> Bool {
        guard let parent = parent else { return false   }
        let newPath = parent.path + "/" + newName + extention
        try? fileManager.moveItem(atPath: path, toPath: newPath)
        name = newName
        path = newPath
        return true
    }
}

