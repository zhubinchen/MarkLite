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
    
    var vertical: String {
        let chars = map{String($0).uppercased()}
        return chars.joined(separator: "\n")
    }
    
    static var unique: String {
        let time = Date().timeIntervalSince1970
        return time.toString
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
    func showAlert(title: String? = nil,
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
            alert.addAction(UIAlertAction(title: /"OK", style: .cancel, handler: nil))
        }
        if let _ = textFieldconfigurationHandler {
            alert.addTextField(configurationHandler: textFieldconfigurationHandler)
        }

        present(alert, animated: true, completion: nil)
        return alert
    }
    
    func showActionSheet(sender: Any? = nil,
                         title: String? = nil,
                         message: String? = nil,
                         actionTitles: [String],
                         actionHandler: ((Int) -> Void)?){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: sender == nil ? .alert : .actionSheet)
        alert.message = message
        for (index, actionTitle) in actionTitles.enumerated() {
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { action in
                actionHandler?(index)
            }))
        }
        alert.addAction(UIAlertAction(title: /"Cancel", style: .cancel, handler: nil))
        if alert.popoverPresentationController != nil {
            guard let sender = sender else { return }
            if let view = sender as? UIView {
                alert.popoverPresentationController?.sourceView = view
                alert.popoverPresentationController?.sourceRect = view.bounds
            }
            if let barButton = sender as? UIBarButtonItem {
                alert.popoverPresentationController?.barButtonItem = barButton
            }
        }
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
        let v = UIActivityIndicatorView(activityIndicatorStyle: Configure.shared.theme.value == .black ? .whiteLarge : .gray)
        v.setColor(.primary)
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
    
    func makeCorner(_ radius: CGFloat, corners: UIRectCorner = UIRectCorner.allCorners) {
        self.layer.mask = nil
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }

}


extension Date {
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

extension UITextField {
    var selectedRange: NSRange? {
        get {
            return nil
        }
        
        set {
            guard let range = newValue else { return }
            let start = position(from: beginningOfDocument, offset: range.location)
            let end = position(from: start!, offset: range.length)
            selectedTextRange = textRange(from: start!, to: end!)
        }
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
            make.left.right.equalTo(0)
            make.height.equalTo(20)
        }
    }
}
