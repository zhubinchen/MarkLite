//
//  File.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/20.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import RxSwift
import RxCocoa

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

extension Int64 {
    var readabelSize: String {
        if self > 1024*1024 {
            let size = String(format: "%.2f", Double(self) / 1024.0 / 1024.0)
            return "\(size) MB"
        } else if self > 1024{
            let size = String(format: "%.2f", Double(self) / 1024.0)
            return "\(size) KB"
        }
        return "\(self) B"
    }
}

fileprivate let fileManager = FileManager.default

class File {
    private(set) var name: String
    private(set) var type: FileType
    private(set) var path: String
    private(set) var modifyDate: Date
    private(set) var size: Int64
        
    lazy var text:Variable<String> = {
        let text = Variable("")
        guard let string = try? String(contentsOfFile: self.path, encoding: String.Encoding.utf8) else {
            return text
        }
        text.value = string
        return text
    }()
    
    var children: [File] {
        return _children
    }
    
    fileprivate weak var parent: File?
    fileprivate var _children: [File] = [File]()
    
    fileprivate var fullName: String {
        return name + type.extensionName
    }
    
    var isTemp = false
    var isSelected = false
    
    init(path:String) {
        self.path = path
        self.name = path.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
        
        if path.hasSuffix(FileType.text.extensionName){
            self.type = .text
        } else {
            self.type = .folder
        }
    
        let attr = try? fileManager.attributesOfItem(atPath: path)
        modifyDate = attr?[FileAttributeKey.modificationDate] as? Date ?? Date()
        size = attr?[FileAttributeKey.size] as? Int64 ?? 0
        
        guard let subPaths = try? fileManager.contentsOfDirectory(atPath: path) else {
            return
        }
        _children = subPaths.filter{($0.components(separatedBy: ".").first ?? "").length > 0}.map{ File(path:self.path + "/" + $0,parent: self) }
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
        let newPath = parent.path + "/" + newName + type.extensionName
        try? fileManager.moveItem(atPath: path, toPath: newPath)
        name = newName
        path = newPath
        return true
    }
}

