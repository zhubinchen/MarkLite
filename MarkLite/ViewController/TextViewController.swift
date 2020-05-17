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
    
    @IBOutlet weak var editView: TextView!
            
    var contentHeight: CGFloat {
//        if _textWidth != editView.w {
//            _textWidth = editView.w
//            let w = _textWidth - editView.contentInset.left * 2
//            _textHeight = editView.sizeThatFits(editView.contentSize).height + editView.contentInset.bottom
//        }
        return editView.contentSize.height
    }
    
    var _textHeight: CGFloat = 0
    
    var _textWidth: CGFloat = 0
    
    var offset: CGFloat = 0.0 {
        didSet {
            var y = offset * (contentHeight - editView.h)
            if y > contentHeight - editView.h  {
                y = contentHeight - editView.h
            }
            if y < 0 {
                y = 0
            }
            editView.contentOffset = CGPoint(x: editView.contentOffset.x,y: y)
        }
    }
    
    var lastOffsetY: CGFloat = 0.0

    var textChangedHandler: ((String)->Void)?
    var didScrollHandler: ((CGFloat)->Void)?

    let bag = DisposeBag()
    let assistBar = KeyboardBar()
    var timer: Timer?
    
    var text: String = ""
    
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
        
        editView.viewController = self
        editView.textContainer.lineBreakMode = .byCharWrapping
        view.setBackgroundColor(.background)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if _textWidth != editView.w {
            updateInset()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let this = self else { return }
            let offset = this.editView.contentOffset.y
            if this.contentHeight - this.editView.h > 0 {
                this.didScrollHandler?(offset / (this.contentHeight - this.editView.h))
            }
        }
    }
    
    func setupRx() {
        
        Configure.shared.isAssistBarEnabled.asObservable().subscribe(onNext: { [unowned self](enable) in
            if enable {
                self.assistBar.textView = self.editView
                self.editView.inputAccessoryView = self.assistBar
            } else {
                self.editView.inputAccessoryView = nil
            }
        }).disposed(by: bag)
        
        Configure.shared.theme.asObservable().subscribe(onNext: { [unowned self] _ in
            self.highlightmanager = MarkdownHighlightManager()
            self.textViewDidChange(self.editView)
        }).disposed(by: bag)
        
        Configure.shared.fontSize.asObservable().subscribe(onNext: { [unowned self] (size) in
            HighlightStyle.boldFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size), weight: UIFont.Weight.medium)
            HighlightStyle.normalFont = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size), weight: UIFont.Weight.regular)
            self.highlightmanager = MarkdownHighlightManager()
            self.textViewDidChange(self.editView)
        }).disposed(by: bag)
    }
    
    func showTOC(_ toc: TOCItem) {
        let expStr = "#+ +\(toc.title)\\s*\n"
        guard let range = editView.text.firstMatchRange(expStr) else { return }
        if let position = editView.position(from: editView.beginningOfDocument, offset: range.location) {
            let rect = editView.caretRect(for: position)
            let y = max(min(rect.y,editView.contentSize.height - editView.h),0)
            editView.setContentOffset(CGPoint(x: editView.contentOffset.x, y: y), animated: true)
        }
    }
    
    func updateInset() {
        let inset = max((self.view.w - 500) * 0.3,0) + 8
        self.editView.contentInset = UIEdgeInsetsMake(0, inset + 8, 20, inset)
        _textWidth = 0
    }
    
    func loadText(_ text: String) {
        self.text = text
        if text.count == 0 {
            editView.becomeFirstResponder()
            return
        }
        if text.length > 800 {
            editView.text = text[0..<800]
            ActivityIndicator.show(on: self.editView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let this = self else { return }
                this.editView.text = text
                this.textViewDidChange(this.editView)
                ActivityIndicator.dismissOnView(this.editView)
            }
        } else {
            editView.text = text
            textViewDidChange(editView)
        }
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
    
    func newLine(_ last: String) -> String {
        if last.hasPrefix("- [x] ") {
            return last + "\n- [x] "
        }
        if last.hasPrefix("- [ ] ") {
            return last + "\n- [ ] "
        }
        if let str = last.firstMatch("^[\\s]*(-|\\*|\\+|([0-9]+\\.)) ") {
            if last.firstMatch("^[\\s]*(-|\\*|\\+|([0-9]+\\.)) +[\\S]+") == nil {
                return "\n"
            }
            guard let range = str.firstMatchRange("[0-9]+") else { return last + "\n" + str }
            let num = str.substring(with: range).toInt() ?? 0
            return last + "\n" + str.replacingCharacters(in: range, with: "\(num+1)")
        }
        if let str = last.firstMatch("^( {4}|\\t)+") {
            return last + "\n" + str
        }
        return last + "\n"
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
            if contentHeight - scrollView.h > 0 {
                didScrollHandler?(offset / (contentHeight - scrollView.h))
            }
        }
        if Configure.shared.autoHideNavigationBar.value == false {
            return
        }
        let pan = scrollView.panGestureRecognizer
        let velocity = pan.velocity(in: scrollView).y
        if velocity < -600 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else if velocity > 600 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if editView.text.count < 5000 {
            return
        }
        if fabs(scrollView.contentOffset.y - lastOffsetY) < 500 {
            return
        }
        timer?.invalidate()
        let contentOffset = editView.contentOffset
        highlight()
        editView.contentOffset = contentOffset
        lastOffsetY = scrollView.contentOffset.y
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIApplication.shared.isIdleTimerDisabled = true
        if Configure.shared.autoHideNavigationBar.value {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIApplication.shared.isIdleTimerDisabled = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let begin = max(range.location - 100, 0)
            let len = range.location - begin
            let nsString = textView.text! as NSString
            let nearText = nsString.substring(with: NSRange(location:begin, length: len))
            let texts = nearText.components(separatedBy: "\n")
            if texts.count < 2 {
                return true
            }
            let lastLineCount = texts.last!.count
            let beginning = textView.beginningOfDocument
            guard let from = textView.position(from: beginning, offset: range.location - lastLineCount), let to = textView.position(from: beginning, offset: range.location), let textRange = textView.textRange(from: from, to: to) else {
                return true
            }
            
            textView.replace(textRange, withText: newLine(texts.last!))
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.text = textView.text
        if editView.markedTextRange != nil {
            return
        }
        textChangedHandler?(text)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(highlight), userInfo: nil, repeats: false)
        _textWidth = 0
    }
}
