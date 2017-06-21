//
//  PathUtils.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/20.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions


let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""

let localPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "") + "MarkLite"

let cloudPath: String? = {
    guard let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
        return nil
    }
    return ubiquityURL.path + "MarkLite"
}()


extension String {
    
    fileprivate func pathByAppendingNumber() -> String {
        if self.length < 3 {
            return self + "(1)"
        }
        
        guard let range = try? NSRegularExpression(pattern: "\\([0-9]+\\)", options: .caseInsensitive).rangeOfFirstMatch(in: self, options: .reportCompletion, range: NSMakeRange(0, self.length)),
            range.location != NSNotFound,
            let num = self[range.location..<range.location+range.length].toInt() else {
                return self + "(1)"
        }
        
        if range.location == NSNotFound {
            return self + "(1)"
        }
        
        return self.replacingCharacters(in: range, with: "(\(num+1))")
    }
    
    var validPath: String {
        guard FileManager.default.fileExists(atPath: self) else {
            return self
        }
        var newPath = self
        let arr = self.components(separatedBy: ".")
        if arr.count > 1 {
            newPath = arr[0].pathByAppendingNumber() + arr[1]
        } else {
            newPath = arr[0].pathByAppendingNumber()
        }
        return newPath.validPath
    }
}
