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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    
    var webVC: WebViewController?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
            scrollView.panGestureRecognizer.require(toFail: popGestureRecognizer)
        }
        Configure.shared.editingFile.asObservable().map{ $0?.name ?? "" }.bind(to: self.rx.title).addDisposableTo(disposeBag)
        Configure.shared.editingFile.value?.readText{ webVC?.text = $0 }
    }
    
    @IBAction func export(_ sender: UIButton) {
        self.view.resignFirstResponder()
        self.scrollView.setContentOffset(CGPoint(x:windowWidth , y:0), animated: true)
        webVC?.showExportMenu()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TextViewController {
            vc.textChangedHandler = { [weak self] text in
                self?.webVC?.text = text
            }

        } else if let vc = segue.destination as? WebViewController {
            webVC = vc
        }
    }
    
    override func shouldBack() -> Bool {
        if scrollView.contentOffset.x > 10 {
            scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
            return false
        }
        return true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textViewWidth.constant = windowWidth > windowHeight ? (windowWidth - 64) * 0.5 : windowWidth
    }
    
    deinit {
        print("deinit edit_vc")
    }
}
