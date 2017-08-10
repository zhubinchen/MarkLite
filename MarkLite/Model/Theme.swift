//
//  Theme.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/8.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift

enum Theme: String {
    case white
    case black
    case green
    case red
    case blue
    case purple
}

enum ThemeColorType {
    case navBar
    case navBarTint
    case primary
    case secondary
}

extension Theme {
    var colors: [UIColor] {
        switch self {
        case .white:
            return [rgba("ffffff",1)!,rgba("333333",1)!,rgba("333333", 0.8)!,rgba("333333", 0.5)!]
        case .black:
            return [rgba("242424",1)!,rgba("ffffff",1)!,rgba("242424", 0.8)!,rgba("242424", 0.5)!]
        case .blue:
            return [rgba("0291D4",1)!,rgba("ffffff",1)!,rgba("0291D4", 0.8)!,rgba("0291D4", 0.5)!]
        case .purple:
            return [rgba("6c16c7",1)!,rgba("ffffff",1)!,rgba("6c16c7", 0.8)!,rgba("6c16c7", 0.5)!]
        case .red:
            return [rgba("D2373B",1)!,rgba("ffffff",1)!,rgba("D2373B", 0.8)!,rgba("D2373B", 0.5)!]
        case .green:
            return [rgba("01BD70",1)!,rgba("ffffff",1)!,rgba("01BD70", 0.8)!,rgba("01BD70", 0.5)!]
        }
    }
    
    var displayName: String {
        switch self {
        case .white:
            return "简洁白"
        case .black:
            return "炫酷黑"
        case .blue:
            return "清新蓝"
        case .red:
            return "中国红"
        case .purple:
            return "风骚紫"
        case .green:
            return "当然是选择原谅她啊"
        }
    }
}

class ColorCenter {
    static let shared = ColorCenter()
    
    let navBar = Variable(UIColor.clear)
    let navBarTint = Variable(UIColor.clear)
    let primary = Variable(UIColor.clear)
    let secondary = Variable(UIColor.clear)
    
    var theme: Theme = .white {
        didSet {
            navBar.value = theme.colors[0]
            navBarTint.value = theme.colors[1]
            primary.value = theme.colors[2]
            secondary.value = theme.colors[3]
        }
    }
    
    func colorVariable(with type: ThemeColorType) -> Variable<UIColor> {
        switch type {
        case .navBar:
            return navBar
        case .navBarTint:
            return navBarTint
        case .primary:
            return primary
        case .secondary:
            return secondary
        }
    }
}

extension UINavigationBar {
    func setBarTintColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.barTintColor = color
            self.setBackgroundImage(UIImage(color: color, size: CGSize(width: 1000, height: 64)), for: .default)
        })
    }
    
    func setContentColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.tintColor = color
            let attr: [String: Any] = [
                NSFontAttributeName: UIFont.font(ofSize: 18),
                NSForegroundColorAttributeName: color
            ]
            self.titleTextAttributes = attr
        })
    }
}

extension UIView {
    func setBackgroundColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self] (color) in
            self.backgroundColor = color
        })
    }
    
    func setTintColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.tintColor = color
        })
    }
}

extension UILabel {
    
    func setTextColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.textColor = color
        })
    }
}

extension UIButton {
    
    func setTitleColor(_ color: ThemeColorType, forState: UIControlState = .normal) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.setTitleColor(color, for: forState)
        })
    }
}

extension UITableView {
    func setSeparatorColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.separatorColor = color * 0.1
        })
    }
}

extension UITextField {
    func setTextColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.textColor = color
        })
    }
}
