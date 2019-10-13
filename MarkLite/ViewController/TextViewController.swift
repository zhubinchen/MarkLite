//
//  TextViewController.swift
//  Markdown
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
    @IBOutlet weak var seperator: UIView!

    @IBOutlet weak var bottomSpace: NSLayoutConstraint!

    var textChangedHandler: ((String,Int?)->Void)?
    var offsetChangedHandler: ((CGFloat)->Void)?

    let bag = DisposeBag()
    var offset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRx()

        addNotificationObserver(Notification.Name.UIKeyboardWillChangeFrame.rawValue, selector: #selector(keyboardWillChange(_:)))
        
        editView.textContainer.lineBreakMode = .byCharWrapping
        view.setBackgroundColor(.background)
        bottomView.setTintColor(.tint)
        countLabel.setTextColor(.secondary)
    }
    
    func setupRx() {
        
        Configure.shared.isAssistBarEnabled.asObservable().subscribe(onNext: { [unowned self](enable) in
            if enable {
                let assistBar = KeyboardBar()
                assistBar.textView = self.editView
                assistBar.viewController = self
                self.editView.inputAccessoryView = assistBar
            } else {
                self.editView.inputAccessoryView = nil
            }
        }).disposed(by: bag)
    }
    
    func didHighlight(attrText: NSAttributedString) {
        editView.isScrollEnabled = false
        let selectedRange = editView.selectedRange
        editView.attributedText = attrText
        editView.selectedRange = selectedRange
        editView.isScrollEnabled = true
    }
    
    @IBAction func undo(_ sender: UIButton) {
        editView.undoManager?.undo()
    }
    
    @IBAction func redo(_ sender: UIButton) {
        editView.undoManager?.redo()
    }
    
    @objc func keyboardWillChange(_ noti: NSNotification) {
        guard let frame = (noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        bottomSpace.constant = max(self.view.h - frame.y + 10,0)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.editView.scrollRangeToVisible(self.editView.selectedRange)
        }
    }
    
    deinit {
        removeNotificationObserver()
        print("deinit text_vc")
    }
}

extension TextViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset == 0 || offset == self.offset {
            return
        }
        self.offset = offset
        offsetChangedHandler?((offset + scrollView.size.height) / max(scrollView.size.height,scrollView.contentSize.height))
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = editView.text ?? ""
        placeholderLabel.isHidden = text.length > 0

        redoButton.isEnabled = self.editView.undoManager?.canRedo ?? false
        undoButton.isEnabled = self.editView.undoManager?.canUndo ?? false

        countLabel.text = text.length.toString + " " + /"Characters"
        if editView.markedTextRange != nil {
            return
        }
        if let range = textView.selectedTextRange {
            let location = editView.offset(from: textView.beginningOfDocument, to: range.start)
            textChangedHandler?(editView.text,location)
        } else {
            textChangedHandler?(editView.text,nil)
        }
    }
}
