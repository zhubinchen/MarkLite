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
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var seperator: UIView!

    @IBOutlet weak var bottomSpace: NSLayoutConstraint!

    var textChangedHandler: ((String)->Void)?
    var offsetChangedHandler: ((CGFloat)->Void)?

    let bag = DisposeBag()
    let assistBar = KeyboardBar()
    var offset: CGFloat = 0.0
    var timer: Timer?
    
    var keyboardHeight: CGFloat = windowHeight {
        didSet {
            bottomSpace.constant = max(windowHeight - keyboardHeight - 40 - bottomInset,0)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                self.editView.scrollRangeToVisible(self.editView.selectedRange)
            }
        }
    }
    
    var highlightmanager = MarkdownHighlightManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRx()
        
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
    
    @objc func highlight() {
        editView.isScrollEnabled = false
        let selectedRange = editView.selectedRange
        editView.attributedText = highlightmanager.highlight(editView.text)
        editView.selectedRange = selectedRange
        editView.isScrollEnabled = true
    }
    
    @IBAction func undo(_ sender: UIButton) {
        editView.undoManager?.undo()
        impactIfAllow()
    }
    
    @IBAction func redo(_ sender: UIButton) {
        editView.undoManager?.redo()
        impactIfAllow()
    }
    
    func newLine(_ last: String) -> String {
        if last.hasPrefix("- [x] ") {
            return "- [x] "
        }
        if last.hasPrefix("- [ ] ") {
            return "- [ ] "
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
        timer?.invalidate()
        removeNotificationObserver()
        print("deinit text_vc")
    }
}

extension TextViewController: UITextViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let pan = scrollView.panGestureRecognizer
//        let velocity = pan.velocity(in: scrollView).y
//        if velocity < -500 {
//            self.navigationController?.setNavigationBarHidden(true, animated: true)
//        } else if velocity > 500 {
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
//        }
        
        let offset = scrollView.contentOffset.y
        if offset == 0 || offset == self.offset {
            return
        }
        self.offset = offset
        offsetChangedHandler?((offset + scrollView.size.height) / max(scrollView.size.height,scrollView.contentSize.height))
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        navigationController?.setNavigationBarHidden(false, animated: true)
        return true
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

        countLabel.text = text.length.toString + " " + /"Characters"
        if editView.markedTextRange != nil {
            return
        }
        textChangedHandler?(editView.text)
        redoButton.isEnabled = self.editView.undoManager?.canRedo ?? false
        undoButton.isEnabled = self.editView.undoManager?.canUndo ?? false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(highlight), userInfo: nil, repeats: false)
    }    
}
