//
//  TextViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/28.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EZSwiftExtensions

class TextViewController: UIViewController {

    @IBOutlet weak var editView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    let disposeBag = DisposeBag()
    let manager = MarkdownHighlightManager()
    var oldTextArray: [String] = []
    var head: Int = 0 {
        didSet {
            canUndo.value = head - 1 < 0
            canRedo.value = head + 1 > oldTextArray.count - 1
        }
    }
    
    let canUndo = Variable(false)
    let canRedo = Variable(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        editView.inputAccessoryView = AssistBar(textView: editView, viewController: self)
        Configure.shared.currentFile.asObservable().subscribe(onNext: { [unowned self] (file) in
            guard let file = file else { return }
            self.editView.text = file.text.value
            self.editView.rx.text.map{ $0 ?? "" }.bind(to: file.text).addDisposableTo(self.disposeBag)
            self.editView.attributedText = self.manager.highlight(file.text.value)
            self.oldTextArray.append(self.editView.text ?? "")
            self.head += 1
        }).addDisposableTo(disposeBag)
        
        editView.rx.observe(String.self, "text").subscribe(onNext: { (text) in
            if (self.editView.markedTextRange == nil) {
                self.oldTextArray.append(text!)
                self.head += 1
                self.editView.attributedText = self.manager.highlight(text!)
            }
        }).addDisposableTo(disposeBag)
        
        editView.rx.text.map{($0?.length ?? 0) > 0}.bind(to: placeholderLabel.rx.isHidden).addDisposableTo(disposeBag)
    }
    
    func undo() {
        if head - 1 < 0 {
            return
        }
        head -= 1
        editView.text = oldTextArray[head]
    }
    
    func redo() {
        if head + 1 > oldTextArray.count - 1 {
            return
        }
        head += 1
        editView.text = oldTextArray[head]
    }
}
