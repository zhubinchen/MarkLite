//
//  Theme.swift
//  Markdown
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
    case pink
}

enum ThemeColorType {
    case navBar
    case navTitle
    case navTint
    case background
    case tableBackground
    case primary
    case secondary
    case tint
    case selectedCell
}

extension Theme {
    var colors: [UIColor] {
        switch self {
        case .white:
            return [rgb("ffffff")!,rgb("161616")!,rgb("4b5cc4")!,rgb("ffffff")!,rgb("F2F2F6")!,rgb("161616")!,rgba("161616", 0.5)!,rgb("4b5cc4")!]
        case .black:
            return [rgb("161616")!,rgb("cccccc")!,rgb("4b5cc4")!,rgb("161616")!,rgb("000000")!,rgb("cccccc")!,rgba("cccccc", 0.5)!,rgb("4b5cc4")!]
        case .blue:
            return [rgb("0291D4")!,rgb("ffffff")!,rgb("ffffff")!,rgb("ffffff")!,rgb("F2F2F6")!,rgb("0291D4")!,rgba("0291D4", 0.5)!,rgb("0291D4")!]
        case .purple:
            return [rgb("6c16c7")!,rgb("ffffff")!,rgb("ffffff")!,rgb("ffffff")!,rgb("F2F2F6")!,rgb("6c16c7")!,rgba("6c16c7", 0.5)!,rgb("6c16c7")!]
        case .red:
            return [rgb("D2373B")!,rgb("ffffff")!,rgb("ffffff")!,rgb("ffffff")!,rgb("F2F2F6")!,rgb("D2373B")!,rgba("D2373B", 0.5)!,rgb("D2373B")!]
        case .green:
            return [rgb("01BD70")!,rgb("ffffff")!,rgb("ffffff")!,rgb("ffffff")!,rgb("F2F2F6")!,rgb("01BD70")!,rgba("01BD70", 0.5)!,rgb("01BD70")!]
        case .pink:
            return [rgb("E52D7C")!,rgb("ffffff")!,rgb("ffffff")!,rgb("ffffff")!,rgb("F2F2F6")!,rgb("E52D7C")!,rgba("E52D7C", 0.5)!,rgb("E52D7C")!]
        }
    }
    
    var displayName: String {
        switch self {
        case .white:
            return /"ThemeWhite"
        case .black:
            return /"ThemeBlack"
        case .blue:
            return /"ThemeBlue"
        case .red:
            return /"ThemeRed"
        case .purple:
            return /"ThemePurple"
        case .pink:
            return /"ThemePink"
        case .green:
            return /"ThemeGreen"
        }
    }
}

class ColorCenter {
    static let shared = ColorCenter()
    
    let navBar = Variable(UIColor.clear)
    let navTitle = Variable(UIColor.clear)
    let navTint = Variable(UIColor.clear)
    let primary = Variable(UIColor.clear)
    let secondary = Variable(UIColor.clear)
    let background = Variable(UIColor.clear)
    let tableBackground = Variable(UIColor.clear)
    let tint = Variable(UIColor.clear)
    let selectedCell = Variable(UIColor.clear)

    var theme: Theme = .white {
        didSet {
            navBar.value = theme.colors[0]
            navTitle.value = theme.colors[1]
            navTint.value = theme.colors[2]
            background.value = theme.colors[3]
            tableBackground.value = theme.colors[4]
            primary.value = theme.colors[5]
            secondary.value = theme.colors[6]
            tint.value = theme.colors[7]
            selectedCell.value = theme == .black ? rgb("151515")! : rgb("e0e0e0")!
        }
    }
    
    func colorVariable(with type: ThemeColorType) -> Variable<UIColor> {
        switch type {
        case .navBar:
            return navBar
        case .navTitle:
            return navTitle
        case .navTint:
            return navTint
        case .primary:
            return primary
        case .secondary:
            return secondary
        case .background:
            return background
        case .tableBackground:
            return tableBackground
        case .tint:
            return tint
        case .selectedCell:
            return selectedCell
        }
    }
}

extension UINavigationBar {
    
    func setTitleColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            let attr1: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: .medium),
                NSAttributedStringKey.foregroundColor: color
            ]
            self.titleTextAttributes = attr1
            
            let attr2: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 32, weight: .medium),
                NSAttributedStringKey.foregroundColor: color
            ]
            if #available(iOS 11.0, *) {
                self.largeTitleTextAttributes = attr2
            }
        })
    }
}

extension UIView {
    func setBackgroundColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self] (color) in
            
            if let navBar = self as? UINavigationBar {
                navBar.barTintColor = color
                navBar.setBackgroundImage(UIImage(color: color, size: CGSize(width: 1000, height: 64)), for: .compact)
            }
            
            self.backgroundColor = color
        })
    }
    
    func setTintColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.tintColor = color
            
            if let imgView = self as? UIImageView, let tintImage = imgView.tintImage {
                imgView.image = tintImage.recolor(color: color)
            }
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
    
    func setPlaceholderColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            let attrString = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedStringKey.foregroundColor:color])
            self.attributedPlaceholder = attrString
        })
    }
}

extension UIActivityIndicatorView {
    func setColor(_ color: ThemeColorType) {
        _ = ColorCenter.shared.colorVariable(with: color).asObservable().takeUntil(rx.deallocated).subscribe(onNext: { [unowned self](color) in
            self.color = color
        })
    }
}

extension UIImageView {
    static let tintImageKey : UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "tintImage:".hashValue)
    var tintImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, UIImageView.tintImageKey) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, UIImageView.tintImageKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            image = newValue?.recolor(color: tintColor)
        }
    }
}
