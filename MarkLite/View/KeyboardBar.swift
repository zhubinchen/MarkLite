//
//  KeyboardBar.swift
//  Markdown
//
//  Created by zhubch on 2017/7/11.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

fileprivate var width: CGFloat = {
    return isPad ? 50 : 40
}()

protocol ButtonConvertiable {
    func makeButton() -> UIButton
}

extension UIImage: ButtonConvertiable {
    func makeButton() -> UIButton {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(self, for: .normal)
        button.contentEdgeInsets = isPad ? UIEdgeInsetsMake(15, 15, 15, 15) : UIEdgeInsetsMake(12, 12, 12, 12)
        return button
    }
}

extension String: ButtonConvertiable {
    func makeButton() -> UIButton {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle(self, for: .normal)
        button.titleLabel?.font = UIFont.font(ofSize: isPad ? 18 : 16, bold: true)
        return button
    }
}

fileprivate let uploadURL = ""
class KeyboardBar: UIView {
    let scrollView = UIScrollView()
    var endButton: UIButton!

    let items: [(ButtonConvertiable,Selector)] = {
        var items: [(ButtonConvertiable,Selector)] = [
        (#imageLiteral(resourceName: "bar_tab"), #selector(tapTab(_:))),
        (#imageLiteral(resourceName: "bar_image"), #selector(tapImage(_:))),
        (#imageLiteral(resourceName: "bar_link"), #selector(tapLink)),
        (#imageLiteral(resourceName: "bar_header"), #selector(tapHeader)),
        (#imageLiteral(resourceName: "bar_bold"), #selector(tapBold)),
        (#imageLiteral(resourceName: "bar_italic"), #selector(tapItalic)),
        (#imageLiteral(resourceName: "highlight"), #selector(tapHighliht)),
        (#imageLiteral(resourceName: "bar_deleteLine"), #selector(tapDeletion)),
        (#imageLiteral(resourceName: "bar_quote"), #selector(tapQuote)),
        (#imageLiteral(resourceName: "bar_code"), #selector(tapCode)),
        (#imageLiteral(resourceName: "bar_olist"), #selector(tapOList)),
        (#imageLiteral(resourceName: "bar_ulist"), #selector(tapUList)),
        (#imageLiteral(resourceName: "bar_todolist"), #selector(tapTodoList))
        ]
        items.append(contentsOf: Configure.shared.keyboardBarItems.mapFilter(mapFunction: { item -> (ButtonConvertiable,Selector) in
            return (item, #selector(tapChar(_:)))
        }))
        return items
    }()
    
    weak var textView: TextView?
    weak var menu: MenuView?
    var textField: UITextField?

    let bag = DisposeBag()
    var imagePicker: ImagePicker?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, w: windowWidth, h: width))

        setBackgroundColor(.tableBackground)
        
        items.forEachEnumerated { (index, item) in
            let button = item.0.makeButton()
            button.addTarget(self, action: item.1, for: .touchUpInside)
            button.tintColor = .gray
            button.tag = index
            button.frame = CGRect(x: CGFloat(index) * width, y: 0, w: width, h: width)
            self.scrollView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: CGFloat(items.count) * width, height: width)
        addSubview(scrollView)
        
        endButton = #imageLiteral(resourceName: "bar_keyboard").makeButton()
        endButton.tintColor = .gray
        endButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        addSubview(endButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0, y: 0, w: w - width, h: width)
        endButton.frame = CGRect(x: w - width, y: 0, w: width, h: width)
        self.menu?.dismiss(sender: self.menu?.superview as? UIControl)
    }
    
    @objc func hideKeyboard() {
        impactIfAllow()
        self.menu?.dismiss(sender: self.menu?.superview as? UIControl)
        textView?.resignFirstResponder()
    }
    
    @objc func tapChar(_ sender: UIButton) {
        let char = sender.currentTitle ?? ""
        textView?.insertText(char)
    }
    
    @objc func tapTab(_ sender: UIButton) {
        self.menu?.dismiss(sender: self.menu?.superview as? UIControl)
        let pos = sender.superview!.convert(sender.center, to: sender.window)
        let menu = MenuView(items: [/"&nbsp;",/"&emsp;",/"Tab"].map{($0,false)},
                 postion: CGPoint(x: pos.x - 20, y: pos.y - 150)) { [weak self] (index) in
                    let texts = ["&nbsp;","&emsp;","\t"]
                    self?.textView?.insertText(texts[index])
        }
        menu.show()
        self.menu = menu
    }

    @objc func tapImage(_ sender: UIButton) {
        self.menu?.dismiss(sender: self.menu?.superview as? UIControl)
        guard let textView = self.textView, let vc = textView.viewController else { return }

        let pos = sender.superview!.convert(sender.center, to: sender.window)
        let menu = MenuView(items: [/"PickFromPhotos",/"PickFromCamera"].map{($0,false)},
                 postion: CGPoint(x: pos.x - 20, y: pos.y - 110)) { [weak self] (index) in
                    if index == 0 {
                        self?.imagePicker = ImagePicker(viewController: vc){ self?.didPickImage($0) }
                        self?.imagePicker?.pickFromLibray()
                    } else if index == 1 {
                        self?.imagePicker = ImagePicker(viewController: vc){ self?.didPickImage($0) }
                        self?.imagePicker?.pickFromCamera()
                    }
        }
        menu.show()
        self.menu = menu
    }
    
    @objc func tapLink() {
        self.menu?.dismiss(sender: self.menu?.superview as? UIControl)
        textView?.viewController?.showAlert(title: /"InsertHref", message: "", actionTitles: [/"Cancel",/"OK"], textFieldconfigurationHandler: { (textField) in
            textField.placeholder = "http://example.com"
            textField.font = UIFont.font(ofSize: 13)
            textField.setTextColor(.primary)
            self.textField = textField
        }) { (index) in
            if index == 1 {
                let link = self.textField?.text ?? ""
                self.textView?.insertURL(link)
            }
        }
    }
    
    @objc func tapCode() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"EnterCode": text
        textView.insertText("`\(insertText)`")
        if isEmpty {
            textView.selectedRange = NSRange(location:currentRange.location + 1, length: insertText.length)
        }
    }
    
    @objc func tapTodoList(_ sender: UIButton) {
        guard let textView = self.textView else { return }
        
        self.menu?.dismiss(sender: self.menu?.superview as? UIControl)
        let pos = sender.superview!.convert(sender.center, to: sender.window)
        let menu = MenuView(items: [/"Completed",/"Uncompleted"].map{($0,false)},
                 postion: CGPoint(x: pos.x - 20, y: pos.y - 110)) { (index) in
                    let currentRange = textView.selectedRange
                    let insertText = "- [\(index == 0 ? "x" : " ")] item"
                    textView.insertText("\n\(insertText)")
                    textView.selectedRange = NSRange(location:currentRange.location + 7, length: (/"item").length)
        }
        menu.show()
        self.menu = menu
    }
    
    @objc func tapUList() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let insertText = "* item"
        textView.insertText("\n\(insertText)")
        textView.selectedRange = NSRange(location:currentRange.location + 3, length: (/"item").length)
    }
    
    @objc func tapOList() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let insertText = "1. item"
        textView.insertText("\n\(insertText)")
        textView.selectedRange = NSRange(location:currentRange.location + 4, length: (/"item").length)
    }
    
    @objc func tapHeader(_ sender: UIButton) {
        guard let textView = self.textView else { return }
        self.menu?.dismiss(sender: self.menu?.superview as? UIControl)
        let pos = sender.superview!.convert(sender.center, to: sender.window)
        let menu = MenuView(items: [/"Header1",/"Header2",/"Header3",/"Header4"].map{($0,false)},
                 postion: CGPoint(x: pos.x - 20, y: pos.y - 190)) { (index) in
                    let currentRange = textView.selectedRange
                    let insertText = ("#" * (index+1)) + " " + /"Header"
                    textView.insertText("\n\(insertText)")
                    textView.selectedRange = NSRange(location:currentRange.location + index + 3, length: (/"Header").length)
        }
        menu.show()
        self.menu = menu
    }
    
    @objc func tapDeletion() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"Delection": text
        textView.insertText("~~\(insertText)~~")
        if isEmpty {
            textView.selectedRange = NSRange(location:currentRange.location + 2, length: insertText.length)
        }
    }
    
    @objc func tapQuote() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let insertText = /"Blockquote"
        textView.insertText("\n> \(insertText)\n")
        textView.selectedRange = NSRange(location:currentRange.location + 3, length: insertText.length)
    }
    
    @objc func tapHighliht() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"Highlight": text
        textView.insertText("==\(insertText)==")
        if isEmpty {
            textView.selectedRange = NSRange(location:currentRange.location + 2, length: insertText.length)
        }
    }
    
    @objc func tapBold() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"StrongText": text
        textView.insertText("**\(insertText)**")
        if isEmpty {
            textView.selectedRange = NSRange(location:currentRange.location + 2, length: insertText.length)
        }
    }
    
    @objc func tapItalic() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"EmphasizedText": text
        textView.insertText("*\(insertText)*")
        if isEmpty {
            textView.selectedRange = NSRange(location:currentRange.location + 1, length: insertText.length)
        }
    }
    
    func didPickImage(_ image: UIImage) {
        imagePicker = nil
        textView?.insertImage(image)
    }
}

//extension KeyboardBar {
//
//    override var keyCommands: [UIKeyCommand]? {
//        return [
//            UIKeyCommand(input: "B", modifierFlags: .command, action: #selector(tapBold), discoverabilityTitle: "Bold"),
//        UIKeyCommand(input: "I", modifierFlags: .command, action: #selector(tapItalic), discoverabilityTitle: "Italic"),
//        ]
//    }
//    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
//}

