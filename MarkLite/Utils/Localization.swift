//
//  Localization.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/21.
//  Copyright © 2017年 zhubch. All rights reserved.
//

prefix operator /

prefix func /(string: String) -> String {
    return string.localizations
}

extension String {
    var localizations: String {
        return NSLocalizedString(self, comment: "")
    }
}
