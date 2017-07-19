//
//  AssistBar.swift
//  MarkLite
//
//  Created by zhubch on 2017/7/11.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

class AssistBar: UIView {
    let scrollView = UIScrollView()
    let items = [
        (#imageLiteral(resourceName: "bar_image"), #selector(tapImage)),
        (#imageLiteral(resourceName: "bar_link"), #selector(tapLink)),
        (#imageLiteral(resourceName: "bar_header"), #selector(tapHeader)),
        (#imageLiteral(resourceName: "bar_bold"), #selector(tapBold)),
        (#imageLiteral(resourceName: "bar_italic"), #selector(tapItalic)),
        (#imageLiteral(resourceName: "bar_deleteLine"), #selector(tapDeletion)),
        (#imageLiteral(resourceName: "bar_quote"), #selector(tapQuote)),
        (#imageLiteral(resourceName: "bar_code"), #selector(tapCode))]
    
    let textView: UITextView
    let imagePicker: ImagePicker
    let vc: UIViewController
    let link = Variable("")
    let disposeBag = DisposeBag()
    
    init(textView: UITextView,viewController: UIViewController) {
        self.textView = textView
        self.vc = viewController
        self.imagePicker = ImagePicker(viewController: viewController, completionHanlder: { (image) in

        })
        super.init(frame: CGRect(x: 0, y: 0, w: windowWidth, h: 50))
        self.backgroundColor = rgb("f2f2f2")
        
        items.forEachEnumerated { (index, item) in
            let button = UIButton(type: UIButtonType.system)
            button.addTarget(self, action: item.1, for: .touchUpInside)
            button.setImage(item.0, for: .normal)
            button.tintColor = .gray
            button.tag = index
            button.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
            button.frame = CGRect(x: CGFloat(index * 50), y: 0, w: 50, h: 50)
            self.scrollView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: items.count * 50, height: 50)
        addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = self.bounds
    }

    func tapImage() {
        DispatchQueue.main.async {
            self.imagePicker.pickImage()
        }
    }
    
    func tapLink() {
        vc.showAlert(title: "请输入链接", message: "", actionTitles: ["取消","确定"], textFieldconfigurationHandler: { (textField) in
            textField.placeholder = "请输入链接"
            textField.text = "http://example.com"
            textField.font = UIFont.font(ofSize: 13)
            textField.textColor = primaryColor
            textField.rx.text.map{$0 ?? ""}.bind(to: self.link).addDisposableTo(self.disposeBag)
        }) { (index) in
            if index == 1 {
                self.insertLink()
            }
        }
    }
    
    func insertLink() {
        if link.value.length == 0 {
            return
        }
        let currentRange = textView.selectedRange
        let insertText = "enter link description here"
        textView.insertText("[enter link description here](\(self.link.value))")
        textView.selectedRange = NSMakeRange(currentRange.location + 1, insertText.length)
    }
    
    func tapCode() {
        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? "enter code here": text
        textView.insertText("`\(insertText)`")
        if isEmpty {
            textView.selectedRange = NSMakeRange(currentRange.location + 1, insertText.length)
        }
    }
    func tapHeader(_ sender: UIButton) {
        let pos = sender.convert(sender.center, to: sender.window)
        MenuView(items: ["一级标题","二级标题","三级标题","四级标题"],
                 postion: CGPoint(x: pos.x - 20, y: pos.y - 200)) { (index) in
            
        }.show()
    }
    func tapDeletion() {
        
    }
    
    func tapQuote() {
        let currentRange = textView.selectedRange
        let insertText = "Blockquote"
        textView.insertText("\n> \(insertText)\n")
        textView.selectedRange = NSMakeRange(currentRange.location + 3, insertText.length)
    }
    
    func tapBold() {
        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? "strong text": text
        textView.insertText("**\(insertText)**")
        if isEmpty {
            textView.selectedRange = NSMakeRange(currentRange.location + 2, insertText.length)
        }
    }
    func tapItalic() {
        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? "emphasized text": text
        textView.insertText("*\(insertText)*")
        if isEmpty {
            textView.selectedRange = NSMakeRange(currentRange.location + 1, insertText.length)
        }
    }
    
    func didPickImage(_ image: UIImage) {
    }
}
