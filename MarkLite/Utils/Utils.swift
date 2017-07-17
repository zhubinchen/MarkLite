//
//  Utils.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/21.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions

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
            newPath = arr[0].pathByAppendingNumber() + "." + arr[1]
        } else {
            newPath = arr[0].pathByAppendingNumber()
        }
        return newPath.validPath
    }
}

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

extension UIViewController {
    @discardableResult
    func showAlert(title: String,
                   message: String? = nil,
                   actionTitles: [String] = [],
                   textFieldconfigurationHandler: ((UITextField) -> Void)?  = nil,
                   actionHandler: ((Int) -> Void)?  = nil) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, actionTitle) in actionTitles.enumerated() {
            alert.addAction(UIAlertAction(title: actionTitle, style: index == 0 ? .cancel : .default, handler: { action in
                actionHandler?(index)
            }))
        }
        if actionTitles.isEmpty {
            alert.addAction(UIAlertAction(title: "好，知道了", style: .cancel, handler: nil))
        }
        if let _ = textFieldconfigurationHandler {
            alert.addTextField(configurationHandler: textFieldconfigurationHandler)
        }
        present(alert, animated: true, completion: nil)
        return alert
    }
    
    func showActionSheet(title: String? = nil,
                         message: String? = nil,
                         actionTitles: [String],
                         actionHandler: ((Int) -> Void)?){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.message = message
        for (index, actionTitle) in actionTitles.enumerated() {
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { action in
                actionHandler?(index)
            }))
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
    public func readableDate() -> (String,String) {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: self)

        if calendar.isDateInToday(self) {
            return ("今天",time)
        }
        
        if calendar.isDateInYesterday(self) {
            return ("昨天",time)
        }
        
        if calendar.compare(Date(), to: self, toGranularity: .year) == .orderedSame {
            dateFormatter.dateFormat = "M月d日"
            return (dateFormatter.string(from: self),time)
        }
        
        dateFormatter.dateFormat = "yyyy年M月d日"
        return (dateFormatter.string(from: self),time)
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
