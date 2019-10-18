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

let locationExtName = ["link"]
let textExtName = ["txt","md"]
let archiveExtName = ["zip"]
let imageExtName = ["png","jpg","jpeg","bmp","tif","pic","gif","heif","heic"]

enum FileType {
    case text
    case archive
    case image
    case folder
    case location
    case other
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
    private(set) var type = FileType.other
    private(set) var isExternalFile = false
    private(set) var opened = false
    private(set) var changed = false
    private(set) weak var parent: File?

    fileprivate(set) static var cloud = File.placeholder(name: /"Cloud")
    fileprivate(set) static var local = File.placeholder(name: /"Local")
    fileprivate(set) static var inbox = File.placeholder(name: /"External")
    fileprivate(set) static var location = File.placeholder(name: /"AddLocation")
    fileprivate(set) static var empty = File.placeholder(name: /"Empty")
    fileprivate(set) static var current: File?

    var children: [File] {
        return _children
    }
    
    var folders: [File] {
        return _children.filter{ $0.type == .folder }
    }
    
    var text: String? {
        get {
            return document?.text
        }
        set {
            if newValue != nil && newValue != document?.text {
                document?.text = newValue!
                document?.updateChangeCount(.done)
                changed = true
            }
        }
    }
    
    var expand = false
        
    var deep: Int {
        if let parent = self.parent {
            return parent.deep + 1
        }
        return 0
    }

    var displayName: String?
    var extensionName = ""

    fileprivate var _children = [File]()
        
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
    
    lazy var document: Document? = {
        if let url = self.url {
            return Document(fileURL: url)
        }
        return nil
    }()
    
    init(path:String) {
        self.path = path
        self.name = path.components(separatedBy: "/").last ?? ""
        
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
        displayName = url.deletingPathExtension().lastPathComponent
        extensionName = url.pathExtension
        if (values.isDirectory ?? false) {
            type = .folder
        }
        
        if locationExtName.contains(extensionName) {
            type = .location
        } else if textExtName.contains(extensionName) {
            type = .text
        } else if archiveExtName.contains(extensionName) {
            type = .archive
        } else if imageExtName.contains(extensionName) {
            type = .image
        }
        
        if type == .text || type == .other || type == .archive {
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
    
    func reloadChildren() {
        if self == File.cloud {
            let url = URL(fileURLWithPath: path)
            try? fileManager.startDownloadingUbiquitousItem(at: url)
        }

        guard let subPaths = try? fileManager.contentsOfDirectory(atPath: path) else {
            return
        }
        _children = subPaths.filter{($0.components(separatedBy: ".").first ?? "").count > 0 && !$0.hasPrefix(".") && !$0.hasPrefix("~")}.map{ File(path:path + "/" + $0,parent: self) }
    }
    
    @discardableResult
    func createFile(name: String, contents: Any? = nil, type: FileType) -> File?{
        let path = (self.path + "/" + name + (type == .text ? ".md" : "")).validPath
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
        do {
            try fileManager.removeItem(atPath: self.path)
            parent?._children.removeAll { $0 == self }
        } catch {
            return false
        }
        return true
    }
    
    @discardableResult
    func move(to newParent: File) -> Bool {
        if newParent == self {
            return false
        }
        if parent != nil && newParent == parent! {
            return false
        }
        let newPath = (newParent.path + "/" + name).validPath
        do {
            try fileManager.moveItem(atPath: path, toPath: newPath)
            parent?._children.removeAll { $0 == self }
            newParent._children.append(self)
            parent = newParent
            path = newPath
        } catch {
            return false
        }
        return true
    }
    
    @discardableResult
    func rename(to newName: String) -> Bool {
        if newName == name {
            return false
        }
        guard let parent = parent else { return false }
        let newPath = parent.path + "/" + newName + extensionName
        if fileManager.fileExists(atPath: newPath) {
            return false
        }
        try? fileManager.moveItem(atPath: path, toPath: newPath)
        displayName = newName
        name = newName + extensionName
        path = newPath
        return true
    }
    
    func close(_ completion:((Bool)->Void)?) {
        synchoronized(token: self) {

            if changed {
                modifyDate = Date()
                if let data = text?.data(using: .utf8) {
                    size = data.count
                }
                changed = false
            }
            if !opened {
                completion?(false)
                if File.current != nil && File.current! == self {
                    File.current = nil
                }
                return
            }
            document?.close{ successed in
                if successed {
                    print("open successed")
                    self.opened = false
                    if File.current != nil && File.current! == self {
                        File.current = nil
                    }
                } else {
                    print("open successed")
                }
                completion?(successed)
            }
        }
    }
    
    func open(_ completion:((String?)->Void)?) {
        synchoronized(token: self) {
            if opened {
                completion?(self.text)
                File.current = self
                return
            }
            document?.open { successed in
                if successed {
                    print("open successed")
                    self.opened = true
                    File.current = self
                    completion?(self.text)
                } else {
                    print("open failed")
                    completion?(nil)
                }
            }
        }
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





