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
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!

    let disposeBag = DisposeBag()
    let manager = MarkdownHighlightManager()
    
    let canUndo = Variable(false)
    let canRedo = Variable(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        editView.backgroundColor = .white
        editView.inputAccessoryView = AssistBar(textView: editView, viewController: self)
        Configure.shared.currentFile.asObservable().subscribe(onNext: { [unowned self] (file) in
            guard let file = file else { return }
            self.editView.attributedText = self.manager.highlight(file.text.value)
            self.editView.rx.text.map{ $0 ?? "" }.bind(to: file.text).addDisposableTo(self.disposeBag)
            self.editView.attributedText = self.manager.highlight(file.text.value)
        }).addDisposableTo(disposeBag)
        
        editView.rx.didChange.subscribe { _ in
            if (self.editView.markedTextRange == nil) {
                self.editView.attributedText = self.manager.highlight(self.editView.text)
            }
        }.addDisposableTo(disposeBag)
        
        editView.rx.text.map{($0?.length ?? 0) > 0}.bind(to: placeholderLabel.rx.isHidden).addDisposableTo(disposeBag)
        
        addNotificationObserver(Notification.Name.UIKeyboardWillChangeFrame.rawValue, selector: #selector(keyboardWillChange(_:)))
    }
    
    @IBAction func export(_ sender: UIButton) {
        let items = ["PDF","图片","markdown","html"]
        let pos = CGPoint(x: windowWidth - 140, y: windowHeight - CGFloat(50) - CGFloat(items.count * 40))
        MenuView(items: items,
                 postion: pos) { (index) in
                    //
            }.show()
    }
    
    @IBAction func chooseTag(_ sender: UIButton) {
        let items = Configure.shared.root.children.map{$0.name}
        let pos = CGPoint(x: sender.x, y: windowHeight - CGFloat(50) - CGFloat(items.count * 40))
        MenuView(items: items, postion: pos) { (index) in
            //
            }.show()
    }
    
    func keyboardWillChange(_ noti: NSNotification) {
        guard let frame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        bottomSpace.constant = max((self.view.h - frame.y - 40),0)
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
}
