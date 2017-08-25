//
//  WrapViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/2.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift

class WrapViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    @IBOutlet weak var leftBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var statusBar: UIView!

    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var leftBar: UIView!

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var leftTitle: UILabel!

    let disposeBag = DisposeBag()
    
    var editVC: EditViewController?
    
    var _popoverPresentationController : UIPopoverPresentationController?
    
    override var popoverPresentationController: UIPopoverPresentationController? {
        return _popoverPresentationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Configure.shared.editingFile.asObservable().map{$0?.name ?? ""}.bind(to: topTitle.rx.text).addDisposableTo(disposeBag)
        Configure.shared.editingFile.asObservable().map{($0?.name ?? "").vertical}.bind(to: leftTitle.rx.text).addDisposableTo(disposeBag)
        
        popoverPresentationController?.delegate = self
        
        statusBar.setBackgroundColor(.background)
        topBar.setBackgroundColor(.navBar)
        leftBar.setBackgroundColor(.navBar)
        topBar.setTintColor(.navBarTint)
        leftBar.setTintColor(.navBarTint)
        topTitle.setTextColor(.navBarTint)
        leftTitle.setTextColor(.navBarTint)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let isLandscape = windowWidth > windowHeight
        Configure.shared.isLandscape.value = isLandscape
        
        topBarHeight.constant = isLandscape ? 20 : 64
        leftBarWidth.constant = isLandscape ? 64 : 0
        
        statusBar.isHidden = !isLandscape
        topBar.isHidden = isLandscape
        leftBar.isHidden = !isLandscape
        
        popoverPresentationController?.presentedViewController.dismissVC(completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let popoverPresentationController = segue.destination.popoverPresentationController, let sourceView = sender as? UIView {
            _popoverPresentationController = popoverPresentationController
            popoverPresentationController.sourceRect = sourceView.bounds
        } else if let vc = segue.destination as? EditViewController {
            editVC = vc
        } else if let vc = segue.destination as? FilesViewController {
            vc.root = Configure.shared.editingFile.value?.parent
        }
    }
    
    @IBAction func export(_ sender: Any) {
        editVC?.showExportMenu(sender)
    }
}
