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

fileprivate let uploadURL = ""
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
    let vc: UIViewController
    let link = Variable("")
    let disposeBag = DisposeBag()
    var imagePicker: ImagePicker!

    init(textView: UITextView,viewController: UIViewController) {
        self.textView = textView
        self.vc = viewController
        super.init(frame: CGRect(x: 0, y: 0, w: windowWidth, h: 50))
        self.imagePicker = ImagePicker(viewController: viewController, completionHanlder: { (image) in
            self.didPickImage(image)
        })
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
        self.imagePicker.pickImage()
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
        textView.insertText("[\(insertText)](\(self.link.value))")
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
                    let currentRange = self.textView.selectedRange
                    let insertText = ("#" * (index+1)) + " Header"
                    self.textView.insertText("\n\(insertText)\n")
                    self.textView.selectedRange = NSMakeRange(currentRange.location + index + 3, "Header".length)
        }.show()
    }
    func tapDeletion() {
        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? "delection": text
        textView.insertText("~~\(insertText)~~")
        if isEmpty {
            textView.selectedRange = NSMakeRange(currentRange.location + 2, insertText.length)
        }
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
        guard let data = UIImageJPEGRepresentation(image, 1) else { return }
        let imagePath = Configure.shared.imageFolderPath + "/temp_\(String.unique).jpg"
        try? data.write(to: URL(fileURLWithPath: imagePath))
        let currentRange = textView.selectedRange
        let insertText = "enter placeholder text here"
        textView.insertText("![\(insertText)](\(imagePath))")
        textView.selectedRange = NSMakeRange(currentRange.location + 2, insertText.length)
        
        upload(multipartFormData: { (formData) in
            if let token = uploadToken.data(using: String.Encoding.utf8) {
                formData.append(token, withName: "Token")
                formData.append(data, withName: "file", mimeType: "image/jpg")
            }
        }, to: imageUploadUrl) { (result) in
            switch result {
            case .success(let upload,_, _):
                upload.responseString(completionHandler: { (response) in
                    if case .success(let string) = response.result {
                        print(string)
                        self.textView.text = self.textView.text.replacingOccurrences(of: imagePath, with: string)
                    } else if case .failure(let error) = response.result {
                        print(error.localizedDescription)
                    }
                })
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
