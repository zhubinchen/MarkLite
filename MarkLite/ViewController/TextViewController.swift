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
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    let manager = MarkdownHighlightManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        editView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        defaultConfigure.currentFile.asObservable().subscribe(onNext: { [unowned self] (file) in
            guard let file = file else { return }
            self.editView.text = file.text.value
            self.editView.rx.text.map{ $0 ?? "" }.bind(to: file.text).addDisposableTo(self.disposeBag)
            self.editView.attributedText = self.manager.highlight(file.text.value)
        }).addDisposableTo(disposeBag)
        editView.rx.didChange.subscribe(onNext: { [unowned self] (_) in
            guard let text = self.editView.text else {return}
            self.editView.attributedText = self.manager.highlight(text)
        }).addDisposableTo(disposeBag)
        editView.rx.text.map{($0?.length ?? 0) > 0}.bind(to: placeholderLabel.rx.isHidden).addDisposableTo(disposeBag)
    }
}
