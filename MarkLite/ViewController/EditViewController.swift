//
//  EditViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditViewController: UIViewController {
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var countLabel: UILabel!

    var textVC: TextViewController!
    var webVC: WebViewController!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Configure.shared.currentFile.asObservable().map{$0?.name ?? ""}.bind(to: rx.title).addDisposableTo(disposeBag)
        
        Configure.shared.currentFile.asObservable().subscribe(onNext: { (file) in
            file?.text.asObservable().map{$0.length.toString + "字"}.bind(to: self.countLabel.rx.text).addDisposableTo(self.disposeBag)
        }).addDisposableTo(disposeBag)
        
        addKeyboardWillHideNotification()
        addKeyboardWillShowNotification()
    }
    
    override func keyboardWillHideWithFrame(_ frame: CGRect) {
        bottomSpace.constant = 0
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func keyboardWillShowWithFrame(_ frame: CGRect) {
        bottomSpace.constant = frame.h - 40
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func export(_ sender: UIButton) {
        let items = ["PDF","图片","markdown","html"]
        let pos = CGPoint(x: sender.x, y: windowHeight - CGFloat(50) - CGFloat(items.count * 40))
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
    
    @IBAction func undo(_ sender: Any) {
        textVC.undo()
    }
    
    @IBAction func redo(_ sender: Any) {
        textVC.redo()
    }
    
    @IBAction func preview(_ sender: Any) {
        scrollView.setContentOffset(CGPoint(x: windowWidth,y: 0) , animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ConfigureViewController {
            vc.preferredContentSize = CGSize(width: 200, height: 300)
        } else if let vc = segue.destination as? TextViewController {
            textVC = vc
        } else if let vc = segue.destination as? WebViewController {
            webVC = vc
        }
    }
}

extension EditViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
