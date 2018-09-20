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
    @IBOutlet weak var seperator: UIView!

    @IBOutlet weak var bottomSpace: NSLayoutConstraint!

    var textChangedHandler: ((String)->Void)?
    var offsetChangedHandler: ((CGFloat)->Void)?

    let disposeBag = DisposeBag()
    var manager = MarkdownHighlightManager()
    var currentFile: File?
    var orignText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRx()

        addNotificationObserver(Notification.Name.UIKeyboardWillChangeFrame.rawValue, selector: #selector(keyboardWillChange(_:)))
        addNotificationObserver(Notification.Name.UIApplicationWillTerminate.rawValue, selector: #selector(applicationWillTerminate))
        
        view.setBackgroundColor(.background)
        bottomView.setTintColor(.primary)
        countLabel.setTextColor(.secondary)
    }
    
    func setupRx() {
        
        Configure.shared.isAssistBarEnabled.asObservable().subscribe(onNext: { [unowned self](enable) in
            if enable {
                let assistBar = AssistBar()
                assistBar.textView = self.editView
                assistBar.viewController = self
                self.editView.inputAccessoryView = assistBar
            } else {
                self.editView.inputAccessoryView = nil
            }
        }).disposed(by: disposeBag)
        
        Configure.shared.isLandscape.asObservable().map{!$0}.bind(to: seperator.rx.isHidden).disposed(by: disposeBag)
        
        Configure.shared.theme.asObservable().subscribe(onNext: { [weak self] _ in
            self?.manager = MarkdownHighlightManager()
            self?.textChanged()
        }).disposed(by: disposeBag)
        
        Configure.shared.editingFile.asObservable().subscribe(onNext: { [weak self] (file) in
            self?.saveFile()
            guard let file = file else { return }
            file.readText{
                self?.editView.text = $0
                self?.orignText = $0
                self?.textChanged()
            }
            self?.currentFile = file
        }).disposed(by: disposeBag)
        
        editView.rx.didChange.subscribe { [weak self] _ in
            self?.textChanged()
            }.disposed(by: disposeBag)
        
        editView.rx.text.map{($0?.length ?? 0) > 0}
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        editView.rx.contentOffset.map{$0.y}.subscribe(onNext: { [weak self] (offset) in
            guard let this = self else { return }
            this.offsetChangedHandler?(offset / this.editView.contentSize.height)
        }).disposed(by: disposeBag)
    }
    
    func textChanged() {
        DispatchQueue.main.async {
            self.redoButton.isEnabled = self.editView.undoManager?.canRedo ?? false
            self.undoButton.isEnabled = self.editView.undoManager?.canUndo ?? false
        }
        
        currentFile?.isBlank = editView.text.trimmed().length == 0

        textChangedHandler?(editView.text)
        countLabel.text = editView.text.length.toString + " " + /"Characters"
        if editView.markedTextRange != nil {
            return
        }
        manager.highlight(editView.text) { [weak self] (attrText) in
            self?.didHighlight(attrText: attrText)  
        }
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
    
    @objc func applicationWillTerminate() {
        saveFile()
    }
    
    func saveFile() {
        if let text = editView.text {
            if text != orignText {
                currentFile?.write(text: text)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveFile()
    }
    
    deinit {
        removeNotificationObserver()
        print("deinit text_vc")
    }
    
}
