//
//  Localization.swift
//  Markdown
//
//  Created by zhubch on 2017/8/21.
//  Copyright © 2017年 zhubch. All rights reserved.
//
import UIKit

fileprivate let ignoreTag = 4654

prefix operator /

prefix func /(string: String) -> String {
    return string.localizations
}

extension String {
    var localizations: String {
        return NSLocalizedString(self, comment: "")
    }
}

protocol Localizable {
    func localize()
}

extension UIButton: Localizable {
    func localize() {
        setTitle(/(title(for: .normal) ?? ""), for: .normal)
        setTitle(/(title(for: .disabled) ?? ""), for: .disabled)
        setTitle(/(title(for: .selected) ?? ""), for: .selected)
    }
}

extension UITextField: Localizable {
    func localize() {
        text = /(text ?? "")
        placeholder = /(placeholder ?? "")
    }
}

extension UILabel: Localizable {
    func localize() {
        text = /(text ?? "")
    }
}

private let swizzling: (UIView.Type) -> () = { view in
    let originalSelector = #selector(view.awakeFromNib)
    let swizzledSelector = #selector(view.swizzled_localization_awakeFromNib)
    
    let originalMethod = class_getInstanceMethod(view, originalSelector)
    let swizzledMethod = class_getInstanceMethod(view, swizzledSelector)
    
    let didAddMethod = class_addMethod(view, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    if didAddMethod {
        class_replaceMethod(view, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    } else {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

extension UIView {
    
    open class func initializeOnceMethod() {
        guard self === UIView.self else {
            return
        }
        
        swizzling(self)
    }
    
    @objc func swizzled_localization_awakeFromNib() {
        swizzled_localization_awakeFromNib()
        
        if let localizableView = self as? Localizable {
            if tag != ignoreTag {
                localizableView.localize()
            }
        }
    }
    
}
