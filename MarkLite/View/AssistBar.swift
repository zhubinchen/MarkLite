//
//  AssistBar.swift
//  MarkLite
//
//  Created by zhubch on 2017/7/11.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import Alamofire

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
    
    init(textView: UITextView,viewController: UIViewController) {
        self.textView = textView
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
        
    }
    func tapCode() {
        
    }
    func tapHeader() {
        
    }
    func tapDeletion() {
        
    }
    
    func tapQuote() {
        
    }
    
    func tapBold() {
        var text = textView.text(in: textView.selectedTextRange ?? UITextRange()) ?? ""
        if text.length == 0 {
            text = "fghj"
        }
        textView.insertText("**\(text)**")
    }
    func tapItalic() {
        
    }
    
    func didPickImage(_ image: UIImage) {
    }
}
