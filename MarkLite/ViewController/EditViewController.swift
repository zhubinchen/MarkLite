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

    var textVC: TextViewController!
    var webVC: WebViewController!
    lazy var configureVC: ConfigureViewController = {
        let vc = ConfigureViewController()
        vc.preferredContentSize = CGSize(width:200, height: 350)
        vc.modalPresentationStyle = .popover
        vc.items = [("设置",["编辑器字体","渲染样式"]),("导出",["PDF","图片","markdown","html"])]
        return vc
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defaultConfigure.currentFile.asObservable().map{$0?.name ?? ""}.bind(to: rx.title).addDisposableTo(disposeBag)
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        guard let popoverVC = configureVC.popoverPresentationController else {
            return
        }
        popoverVC.delegate = self
        popoverVC.barButtonItem = sender
        present(configureVC, animated: true, completion: nil)
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
