//
//  DropboxHelper.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/11.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SwiftyDropbox

let dropbox = DropboxHelper()

class DropboxHelper {
    
    let client = DropboxClient(accessToken: dropboxToken)
    func authInViewController(_ vc: UIViewController) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: vc) { (url) in
            UIApplication.shared.open(url, options: [ : ], completionHandler: {(success) in})
        }
    }
    
    func loadFiles(_ completion:@escaping (File)->Void) {
        
        let root = File(path: "")
        client.files.listFolder(path: "", recursive: true, includeMediaInfo: false, includeDeleted: false, includeHasExplicitSharedMembers: false).response { (result, error) in
            defer {
                completion(root)
            }
            guard let entries = result?.entries else {
                return
            }
            entries.forEach{ metadata in
                guard let path = metadata.pathDisplay else { return }
                if let p = root.childAtPath(path.stringByDeleteLastPath()) {
                    p.appendChild(path)
                } else {
                    root.appendChild(path)
                }
            }
        }

    }
    
    func download(file: File, completion:@escaping (String?,Error?)->Void) {
        client.files.download(path: file.path).progress({ (progress) in
            let completed = progress.completedUnitCount
            let total = progress.totalUnitCount
            print("\(completed)/\(total)")
        }).response { (result, error) in
            
            if let result = result {
                let text = String(data: result.1, encoding: String.Encoding.utf8)
                completion(text, nil)
            }
        }
    }
    
    func upload(file: File) {
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: file.tempPath)) else { return }
        client.files.upload(path: file.tempPath, input: data).progress({ (progress) in
            let completed = progress.completedUnitCount
            let total = progress.totalUnitCount
            print("\(completed)/\(total)")
        }).response { (result, error) in
            
        }
    }
    
    func createfolder(_ completion:@escaping (File)->Void) {
        client.files.createFolder(path: "/zbc/the").response { (result, error) in
            print(result?.name ?? "")
        }
    }
    
}

