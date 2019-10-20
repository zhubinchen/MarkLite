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
    let assistBar = KeyboardBar()
    var offset: CGFloat = 0.0
    
    var highlightmanager = MarkdownHighlightManager()

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
                self.assistBar.textView = self.editView
                self.assistBar.viewController = self
                self.editView.inputAccessoryView = self.assistBar
            } else {
                self.editView.inputAccessoryView = nil
            }
        }).disposed(by: bag)
        
        Configure.shared.theme.asObservable().subscribe(onNext: { [unowned self] _ in
            self.highlightmanager = MarkdownHighlightManager()
            self.textViewDidChange(self.editView)
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
        bottomSpace.constant = max(windowHeight - frame.y - 50,0)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.editView.scrollRangeToVisible(self.editView.selectedRange)
        }
    }
    
    func newLine(_ last: String) -> String {
        if last.hasPrefix("- [x] ") {
            return "- [x] "
        }
        if last.hasPrefix("- [] ") {
            return "- [] "
        }
        if let str = last.firstMatch("^[\\s]*(-|\\*|\\+|([0-9]+\\.)) ") {
            guard let range = str.firstMatchRange("[0-9]+") else { return str }
            let num = str.substring(with: range).toInt() ?? 0
            return str.replacingCharacters(in: range, with: "\(num+1)")
        }
        if let str = last.firstMatch("^( {4}|\\t)+") {
            return str
        }
        return ""
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let begin = max(range.location - 100, 0)
            let len = range.location - begin
            let nsString = textView.text! as NSString
            let nearText = nsString.substring(with: NSMakeRange(begin, len))
            let texts = nearText.components(separatedBy: "\n")
            if texts.count < 2 {
                return true
            }
            textView.insertText("\n"+newLine(texts.last!))
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let text = editView.text ?? ""
        placeholderLabel.isHidden = text.length > 0
        countLabel.text = text.length.toString + " " + /"Characters"
        if editView.markedTextRange != nil {
            return
        }
        textChangedHandler?(editView.text,nil)
        let attrText = self.highlightmanager.highlight(text)
        didHighlight(attrText: attrText)
        redoButton.isEnabled = self.editView.undoManager?.canRedo ?? false
        undoButton.isEnabled = self.editView.undoManager?.canUndo ?? false
        
//        if let range = textView.selectedTextRange {
//            let location = editView.offset(from: textView.beginningOfDocument, to: range.start)
//            textChangedHandler?(editView.text,location)
//        } else {
//            textChangedHandler?(editView.text,nil)
//        }
    }    
}
