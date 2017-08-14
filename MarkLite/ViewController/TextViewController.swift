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
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var bottomSpace: NSLayoutConstraint!

    var textChangedHandler: ((String)->Void)?

    let disposeBag = DisposeBag()
    let manager = MarkdownHighlightManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let assistBar = AssistBar()
        assistBar.textView = editView
        assistBar.viewController = self
        editView.inputAccessoryView = assistBar
        editView.backgroundColor = .white

        Configure.shared.editingFile.asObservable().subscribe(onNext: { [weak self] (file) in
            guard let file = file else { return }
            file.readText{
                self?.editView.text = $0
                self?.textChanged()
            }
        }).addDisposableTo(disposeBag)
        
        editView.rx.didChange.subscribe { [weak self] _ in
            self?.textChanged()
        }.addDisposableTo(disposeBag)
        
        editView.rx.text.map{($0?.length ?? 0) > 0}
            .bind(to: placeholderLabel.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        addNotificationObserver(Notification.Name.UIKeyboardWillChangeFrame.rawValue, selector: #selector(keyboardWillChange(_:)))
    }
    
    func textChanged() {
        textChangedHandler?(editView.text ?? "")

        if editView.markedTextRange != nil {
            return
        }
        editView.isScrollEnabled = false
        let selectedRange = editView.selectedRange
        editView.attributedText = manager.highlight(editView.text)
        editView.selectedRange = selectedRange;
        editView.isScrollEnabled = true
    }
    
    @IBAction func undo(_ sender: UIButton) {
        editView.undoManager?.undo()
        
        self.redoButton.isEnabled = self.editView.undoManager?.canRedo ?? false
        self.undoButton.isEnabled = self.editView.undoManager?.canUndo ?? false
    }
    
    @IBAction func redo(_ sender: UIButton) {
        editView.undoManager?.redo()
        self.redoButton.isEnabled = self.editView.undoManager?.canRedo ?? false
        self.undoButton.isEnabled = self.editView.undoManager?.canUndo ?? false
    }
    
    func keyboardWillChange(_ noti: NSNotification) {
        guard let frame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        bottomSpace.constant = self.view.h - frame.y
        editView.scrollRangeToVisible(editView.selectedRange)
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        print("deinit text_vc")
    }
    
}
