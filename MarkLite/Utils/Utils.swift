//
//  Utils.swift
//  Markdown
//
//  Created by zhubch on 2017/6/21.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import RxSwift
import CommonCrypto

func *(string: String, repeatCount: Int) -> String {
    var ret = ""
    for _ in 0..<repeatCount {
        ret += string
    }
    return ret
}

func synchoronized(token: Any, block: ()->Void) {
    objc_sync_enter(token)
    defer {
        objc_sync_exit(token)
    }
    block()
}

func impactIfAllow() {
    if !Configure.shared.impactFeedback {
        return
    }
    let impactGenerator: UIImpactFeedbackGenerator = {
        if #available(iOS 13.0, *) {
            return UIImpactFeedbackGenerator(style: .rigid)
        }
        return UIImpactFeedbackGenerator(style: .medium)
    }()
    impactGenerator.impactOccurred()
}

extension String {
    
    func md5() ->String!{
        let str = cString(using: .utf8)
        let strLen = CUnsignedInt(lengthOfBytes(using: .utf8))
        let digestLen = CC_MD5_DIGEST_LENGTH
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(digestLen))
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[Int(i)])
        }
        result.deallocate()
        return String(format: hash as String)
    }
    
    func stringByDeleteLastPath() -> String {
        var paths = self.components(separatedBy: "/")
        paths.removeLast()
        return paths.joined(separator: "/")
    }
    
    fileprivate func pathByAppendingNumber() -> String {
        if self.length < 3 {
            return self + "(1)"
        }
        
        guard let range = try? NSRegularExpression(pattern: "\\([0-9]+\\)", options: .caseInsensitive).rangeOfFirstMatch(in: self, options: .reportCompletion, range: NSMakeRange(0, self.length)) else {
                return self + "(1)"
        }
                
        if range.location == NSNotFound {
            return self + "(1)"
        }
        
        let num = self[range.location+1..<range.location+range.length-1].toInt() ?? 0
        
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
    
    var isValidFileName: Bool {
        let pattern = "^[^\\.\\*\\:/]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
    
    static var unique: String {
        let time = Date().timeIntervalSince1970
        return time.toString
    }
    
    func firstMatch(_ exp: String) -> String? {
        guard let range = firstMatchRange(exp) else { return nil }
        return substring(with: range)
    }
    
    func firstMatchRange(_ exp: String) -> NSRange? {
        guard let exp = try? NSRegularExpression(pattern: exp, options: .anchorsMatchLines) else { return nil }
        guard let range = exp.firstMatch(in: self, options: .anchored, range: NSMakeRange(0, min(20, self.count)))?.range else { return nil }
        if range.location == NSNotFound {
            return nil
        }
        return range
    }
    
    func substring(with nsRange: NSRange) -> String {
        return self.substring(with: rangeFromNSRange(nsRange)!)
    }
    
    func replacingCharacters(in nsRange: NSRange, with newString: String) -> String {
        return self.replacingCharacters(in: rangeFromNSRange(nsRange)!, with: newString)
    }
    
    func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        let from16 = utf16.index(startIndex, offsetBy: nsRange.location)
        let to16 = index(from16, offsetBy: nsRange.length)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
            return from ..< to
        }
        return nil
    }
}


extension UIViewController {
    
    @discardableResult
    func showDestructiveAlert(title: String? = nil,
                   message: String? = nil,
                   actionTitle: String? = nil,
                   actionHandler: (() -> Void)?  = nil) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: isPad ? .alert : .actionSheet)
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { action in
            actionHandler?()
        }))
        
        alert.addAction(UIAlertAction(title: /"Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
        return alert
    }
    
    @discardableResult
    func showAlert(title: String? = nil,
                   message: String? = nil,
                   actionTitles: [String] = [],
                   textFieldconfigurationHandler: ((UITextField) -> Void)?  = nil,
                   actionHandler: ((Int) -> Void)?  = nil) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let last = actionTitles.count - 1
        for (index, actionTitle) in actionTitles.enumerated() {
            alert.addAction(UIAlertAction(title: actionTitle, style: index == last ? .cancel : .default, handler: { action in
                actionHandler?(index)
            }))
        }
        if actionTitles.isEmpty {
            alert.addAction(UIAlertAction(title: /"OK", style: .cancel, handler: nil))
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
                         actionHandler: ((Int) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: isPad ? .alert : .actionSheet)
        alert.message = message
        for (index, actionTitle) in actionTitles.enumerated() {
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { action in
                actionHandler?(index)
            }))
        }
        alert.addAction(UIAlertAction(title: /"Cancel", style: .cancel, handler: nil))
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
}

extension Date {
    
    public static func longlongAgo() -> Date {
        return Date(timeIntervalSince1970: 0)
    }
    
    public func daysAgo(_ days: NSInteger) -> Date {
        return addingTimeInterval(TimeInterval(-3600*24*days))
    }
    
    public func daysAfter(_ days: NSInteger) -> Date {
        return addingTimeInterval(TimeInterval(3600*24*days))
    }
    
    public func readableDate() -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: self)

        if calendar.isDateInToday(self) {
            return /"Today" + " " + time
        }
        
        if calendar.isDateInYesterday(self) {
            return /"Yesterday" + " " + time
        }
        
        if calendar.compare(Date(), to: self, toGranularity: .year) == .orderedSame {
            dateFormatter.dateFormat = /"M-d"
            return dateFormatter.string(from: self)
        }
        
        dateFormatter.dateFormat = /"yyyy-M-d"
        return dateFormatter.string(from: self)
    }
}

extension UIFont {
    static func font(ofSize: CGFloat,bold: Bool = false) -> UIFont {
        if bold {
            return boldSystemFont(ofSize: ofSize)
        }
        return systemFont(ofSize: ofSize)
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

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        
        self.init(cgImage: cgImage)
    }
    
    public func recolor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, w: self.size.width, h: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage ?? self;
    }
}

extension UIScrollView {
    
    var snap: UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(contentSize, isOpaque, 0.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        let savedContentOffset = contentOffset
        let savedFrame = frame
        defer {
            contentOffset = savedContentOffset
            frame = savedFrame
        }
        
        contentOffset = CGPoint(x: 0, y: 0)
        let size = CGSize(width: contentSize.width, height: contentSize.height)
        frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        layer.render(in: ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
}

extension UITableView {
    func addPullDownView(_ view: UIView, bag: DisposeBag, comletion:@escaping ()->Void) {
        addSubview(view)
        rx.didEndDragging.subscribe(onNext: { [unowned self] (end) in
            if self.contentOffset.y < -60 {
                comletion()
            }
        }).disposed(by: bag)
        
        view.snp_makeConstraints { make in
            make.top.equalTo(-40)
            make.centerX.equalTo(self)
            make.height.equalTo(20)
        }
    }
}
