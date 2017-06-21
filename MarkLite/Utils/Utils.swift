//
//  Utils.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/21.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

extension String {
    func replacingCharacters(in nsRange: NSRange, with newString: String) -> String {
        return self.replacingCharacters(in: rangeFromNSRange(nsRange)!, with: newString)
    }
    
    func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advanced(by: nsRange.location)
        let to16 = from16.advanced(by: nsRange.length)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
            return from ..< to
        }
        return nil
    }
}

