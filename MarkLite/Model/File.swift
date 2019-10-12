//
//  File.swift
//  Markdown
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
    case location

    var extensionName: String {
        switch self {
        case .text:
            return ".md"
        case .location:
            return ".link"
        default:
            return ""
        }
    }
}

extension Int {
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
    private(set) var path: String
    private(set) var modifyDate = Date()
    private(set) var size = 0
    private(set) var disable = false
    private(set) var type = FileType.text
    private(set) var isExternalFile = false

    fileprivate(set) static var cloud = File.placeholder(name: /"Cloud")
    fileprivate(set) static var local = File.placeholder(name: /"Local")
    fileprivate(set) static var inbox = File.placeholder(name: /"External")
    fileprivate(set) static var location = File.placeholder(name: /"AddLocation")

    var children: [File] {
        return _children
    }
    
    var folders: [File] {
        return _children.filter{ $0.type == .folder }
    }
    
    lazy var text: String = read() ?? ""
    
    var expand = false
    
    var deep: Int {
        if let parent = self.parent {
            return parent.deep + 1
        }
        return 0
    }

    var displayName: String?
    
    fileprivate(set) weak var parent: File?
    
    fileprivate var _text: String?
    
    fileprivate var _children = [File]()
    
    fileprivate var fullName: String {
        return name + type.extensionName
    }
        
    fileprivate lazy var externalURL: URL? = {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        var stale = false
        let url = try? URL(resolvingBookmarkData: data, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &stale)
        return url ?? nil
    }()
    
    var url: URL? {
        if isExternalFile {
            return externalURL
        }
        return URL(fileURLWithPath: path)
    }
    
    init(path:String) {
        self.path = path
        self.name = path.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
        
        if (path.hasPrefix(inboxPath) && path != inboxPath) || (path.hasPrefix(locationPath) && path != locationPath) {
            isExternalFile = true
        }
        
        if path.count == 0 {
            disable = true
            type = .folder
            return
        }

        var accessed = false
        if isExternalFile {
            accessed = self.externalURL?.startAccessingSecurityScopedResource() ?? false
        }
        
        defer {
            if accessed {
                self.externalURL?.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let url = self.url, let values = try? url.resourceValues(forKeys: [URLResourceKey.isDirectoryKey,.contentModificationDateKey,.fileSizeKey]) else {
            disable = true
            return
        }
                
        if (values.isDirectory ?? false) {
            type = .folder
        }
        
        if path.hasSuffix(FileType.location.extensionName) {
            type = .location
        }
        
        if type == .text {
            modifyDate = values.contentModificationDate ?? Date()
            size = values.fileSize ?? 0
            return
        }
        guard let subPaths = try? fileManager.contentsOfDirectory(atPath: url.path) else {
            return
        }
        if accessed {
            accessed = false
            self.externalURL?.stopAccessingSecurityScopedResource()
        }
        _children = subPaths.filter{($0.components(separatedBy: ".").first ?? "").length > 0 && !$0.hasPrefix(".") && !$0.hasPrefix("~")}.map{ File(path:url.path + "/" + $0,parent: self) }
    }
    
    convenience init(path: String, parent: File) {
        self.init(path: path)
        self.parent = parent
    }
    
    class func placeholder(name: String) -> File {
        let file = File(path: "")
        file.disable = true
        file.displayName = name
        return file
    }
    
    public static func ==(lhs: File, rhs: File) -> Bool {
        if lhs.path.count + rhs.path.count == 0 {
            return lhs.displayName == rhs.displayName
        }
        return lhs.path == rhs.path
    }
    
    func childAtPath(_ path: String) -> File? {
        if self.path == path {
            return self
        }
        
        for child in children {
            if let c = child.childAtPath(path) {
                return c
            }
        }
        return nil
    }
    
    func appendChild(_ path: String) {
        let file = File(path: path, parent: self)
        _children.append(file)
    }
    
    @discardableResult
    func createFile(name: String, contents: Any? = nil, type: FileType) -> File?{
        let path = (self.path + "/" + name + type.extensionName).validPath
        if type == .folder {
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } else {
            if let data = contents as? Data {
                fileManager.createFile(atPath: path, contents: data, attributes: nil)
            } else if let text = contents as? String {
                let data = text.data(using: .utf8)
                fileManager.createFile(atPath: path, contents: data, attributes: nil)
            } else {
                fileManager.createFile(atPath: path, contents: nil, attributes: nil)
            }
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
    
    @discardableResult
    func save() -> Bool {
        if text == _text {
            return true
        }
        
        guard let data = text.data(using: String.Encoding.utf8) else { return false }
        
        var url = URL(fileURLWithPath: self.path)

        if isExternalFile {
            let accessed = externalURL?.startAccessingSecurityScopedResource() ?? false
            if accessed {
                url = externalURL!
            } else {
                return false
            }
        }
        
        defer {
            if isExternalFile {
                externalURL?.stopAccessingSecurityScopedResource()
            }
        }

        do {
            try data.write(to: url)
            _text = text
        } catch {
            print("error to save file at:\(path)")
            return false
        }
        modifyDate = Date()
        size = data.count
        return true
    }
    
    func read() -> String? {
        if isExternalFile {
            let path = externalURL?.path ?? ""
            let accessed = externalURL?.startAccessingSecurityScopedResource() ?? false
            if accessed {
                _text = (try? String(contentsOfFile: path, encoding: String.Encoding.utf8))
                externalURL?.stopAccessingSecurityScopedResource()
            }
        } else {
            _text = (try? String(contentsOfFile: self.path, encoding: String.Encoding.utf8))
        }
        return _text
    }
}

extension File {
    
    class func loadLocation(_ completion: @escaping (File)->Void) {
        DispatchQueue.global().async {
            let location = File(path: locationPath)
            location.displayName = /"AddLocation"
            File.location = location
            DispatchQueue.main.sync {
                completion(location)
            }
        }
    }
    
    class func loadInbox(_ completion: @escaping (File)->Void) {
        DispatchQueue.global().async {
            let inbox = File(path: inboxPath)
            inbox.displayName = /"External"
            File.inbox = inbox
            DispatchQueue.main.sync {
                completion(inbox)
            }
        }
    }
    
    class func loadLocal(_ completion: @escaping (File)->Void) {
        DispatchQueue.global().async {
            let local = File(path: documentPath)
            local.displayName = /"Local"
            File.local = local
            DispatchQueue.main.sync {
                completion(local)
            }
        }
    }
    
    class func loadCloud(_ completion: @escaping (File)->Void) {
        DispatchQueue.global().async {
            let url = URL(fileURLWithPath: cloudPath)
            try? fileManager.startDownloadingUbiquitousItem(at: url)
            let cloud = File(path: cloudPath)
            if cloudPath.count == 0 {
                cloud.disable = true
            }
            cloud.displayName = /"Cloud"
            File.cloud = cloud
            DispatchQueue.main.sync {
                 completion(cloud)
            }
        }
    }
}





