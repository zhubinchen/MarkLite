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
    
    var textViewWidth: CGFloat = 0
    
    var textHeight: CGFloat {
        if editView.w != textViewWidth {
            textViewWidth = editView.w
            _textHeight = editView.sizeThatFits(editView.size).height
        }
        return _textHeight
    }
    
    var _textHeight: CGFloat = 0
    
    var offset: CGFloat = 0.0 {
        didSet {
            var y = offset * (textHeight - editView.h)
            if y > textHeight - editView.h  {
                y = textHeight - editView.h
            }
            if y < 0 {
                y = 0
            }
            editView.contentOffset = CGPoint(x: 0,y: y)
        }
    }
    
    var lastOffsetY: CGFloat = 0.0

    var textChangedHandler: ((String)->Void)?
    var didScrollHandler: ((CGFloat)->Void)?

    let bag = DisposeBag()
    let assistBar = KeyboardBar()
    var timer: Timer?
    
    var text: String = ""
        
    var keyboardHeight: CGFloat = windowHeight {
        didSet {
            if keyboardHeight == oldValue {
                return
            }
            
            bottomSpace.constant = max(keyboardHeight - bottomInset - 40,0)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    var visibleRange: NSRange? {
        let topLeft = CGPoint(x: editView.bounds.minX, y: editView.bounds.minY)
        let bottomRight = CGPoint(x: editView.bounds.maxX, y: editView.bounds.maxY)
        guard let topLeftTextPosition = editView.closestPosition(to: topLeft),
            let bottomRightTextPosition = editView.closestPosition(to: bottomRight) else {
                return nil
        }
        let location = editView.offset(from: editView.beginningOfDocument, to: topLeftTextPosition)
        let length = editView.offset(from: topLeftTextPosition, to: bottomRightTextPosition)
        return NSRange(location: location, length: length)
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
        
        Configure.shared.fontSize.asObservable().subscribe(onNext: { (size) in
            HighlightStyle.boldFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size), weight: UIFont.Weight.medium)
            HighlightStyle.normalFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size), weight: UIFont.Weight.regular)
            self.highlightmanager = MarkdownHighlightManager()
            self.textViewDidChange(self.editView)
        }).disposed(by: bag)
    }
    
    func loadText(_ text: String) {
        self.text = text
        if text.count == 0 {
            editView.becomeFirstResponder()
        }
        editView.text = text
        textViewDidChange(editView)
    }
    
    func appendText(_ text: String) {
        
    }
    
    @objc func highlight() {
        if editView.text.count < 5000 {
            highlightmanager.highlight(editView.textStorage,visibleRange: nil)
        } else if let range = self.visibleRange {
            highlightmanager.highlight(editView.textStorage,visibleRange: range)
        }
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
        if scrollView.isDragging {
            let offset = scrollView.contentOffset.y
            if textHeight - scrollView.h > 0 {
                didScrollHandler?(offset / (textHeight - scrollView.h))
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if editView.text.count < 5000 {
            return
        }
        if fabs(scrollView.contentOffset.y - lastOffsetY) < 500 {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(highlight), userInfo: nil, repeats: false)
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIApplication.shared.isIdleTimerDisabled = false
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
        self.text = textView.text
        countLabel.text = "\(text.count) " + /"Characters"
        if editView.markedTextRange != nil {
            return
        }
        textChangedHandler?(text)
        redoButton.isEnabled = self.editView.undoManager?.canRedo ?? false
        undoButton.isEnabled = self.editView.undoManager?.canUndo ?? false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(highlight), userInfo: nil, repeats: false)
        textViewWidth = 0
    }
}
