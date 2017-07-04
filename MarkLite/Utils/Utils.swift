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

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return 0.0
        }
        set(newValue) {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor()
        }
        set(newValue) {
            layer.borderColor = newValue.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return 0.0
        }
        set(newValue) {
            layer.borderWidth = newValue
            
        }
    }
    
    func startLoadingAnimation() {
        stopLoadingAnimation()
        let bg = UIView(frame: bounds)
        bg.tag = 4654
        if self is UIButton {
            bg.backgroundColor = backgroundColor
        } else {
            bg.backgroundColor = UIColor.clear
        }
        let v = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        bg.addSubview(v)
        v.center = bg.center
        v.startAnimating()
        addSubview(bg)
    }
    
    func stopLoadingAnimation() {
        if let v = viewWithTag(4654) {
            v.removeFromSuperview()
        }
    }
    
    func showDottedLineBorder(color: UIColor, cornerRadius: CGFloat) {
        let border = CAShapeLayer()
        border.strokeColor = color.cgColor
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        border.frame = bounds
        border.lineWidth = 0.5
        border.lineCap = "square"
        border.lineDashPattern = [4,2]
        layer.addSublayer(border)
    }
    
    convenience init(hexString: String) {
        self.init(frame: CGRect.zero)
        backgroundColor = UIColor(hexString: hexString)
    }
}


extension Date {
    public func readableDate() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            let beforeSecond = Date().timeIntervalSince(self)
            if beforeSecond >= 3600 { // 1小时前
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "今天 HH:mm"
                return dateFormatter.string(from: self)
            } else if beforeSecond >= 60 { // 1分钟前
                return "\(Int(ceil(beforeSecond / 60))) 分钟前"
            } else {
                return "刚刚"
            }
        }
        
        if calendar.isDateInYesterday(self) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "昨天 HH:mm"
            return dateFormatter.string(from: self)
        }
        
        if calendar.compare(Date(), to: self, toGranularity: .year) == .orderedSame {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M月d日 HH:mm"
            return dateFormatter.string(from: self)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日 HH:mm"
        return dateFormatter.string(from: self)
    }
}

extension UIFont {
    static func font(ofSize: CGFloat) -> UIFont {
        return self.systemFont(ofSize:ofSize)
    }
}

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> UIColor {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

func rgb(_ hexString: String) -> UIColor? {
    return UIColor(hexString: hexString)
}

func rgba(_ hexString: String,_ alpha: CGFloat) -> UIColor? {
    return UIColor(hexString: hexString, alpha: alpha)
}

func *(color: UIColor, alpha: CGFloat) -> UIColor {
    return color.withAlphaComponent(alpha)
}

func range(_ loc: Int, _ len: Int) -> NSRange {
    return NSMakeRange(loc, len)
}
