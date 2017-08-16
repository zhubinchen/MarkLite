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
    
    var showExport = true
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let popGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
            scrollView.panGestureRecognizer.require(toFail: popGestureRecognizer)
        }
        
        scrollView.rx.contentOffset.map{ $0.x > windowWidth - 10 }.subscribe(onNext: { [weak self] showExport in
            self?.toggleBarButton(showExport)
        }).addDisposableTo(disposeBag)
        
        Configure.shared.editingFile.asObservable().map{ $0?.name ?? "" }.bind(to: self.rx.title).addDisposableTo(disposeBag)
        
        Configure.shared.editingFile.value?.readText{ [weak self] text in
            self?.webVC?.text = text
        }
    }
    
    func toggleBarButton(_ showExport: Bool) {
        if self.showExport == showExport {
            return
        }
        self.showExport = showExport
        if showExport {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "export"), style: .plain, target: self, action: #selector(export))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(preview))
        }
    }
    func export() {
        self.view.resignFirstResponder()
        webVC?.showExportMenu()
    }
    
    func preview() {
        self.view.resignFirstResponder()
        self.scrollView.setContentOffset(CGPoint(x:windowWidth , y:0), animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TextViewController {
            vc.textChangedHandler = { [weak self] text in
                self?.webVC?.text = text
            }
            vc.offsetChangedHandler = { [weak self] offset in
                self?.webVC?.offset = offset
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
