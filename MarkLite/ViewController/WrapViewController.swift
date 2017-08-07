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
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var leftBar: UIView!

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var leftTitle: UILabel!

    let disposeBag = DisposeBag()
    
    var _popoverPresentationController : UIPopoverPresentationController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Configure.shared.isLandscape.value ? .default : .lightContent
    }
    
    override var popoverPresentationController: UIPopoverPresentationController? {
        return _popoverPresentationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Configure.shared.currentFile.asObservable().map{$0?.name ?? ""}.bind(to: topTitle.rx.text).addDisposableTo(disposeBag)
        Configure.shared.currentFile.asObservable().map{$0?.name ?? ""}.bind(to: leftTitle.rx.text).addDisposableTo(disposeBag)
        Configure.shared.currentFile.value = Configure.shared.root.children.first
        
        self.popoverPresentationController?.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let isLandscape = windowWidth > windowHeight
        Configure.shared.isLandscape.value = isLandscape
        
        topBarHeight.constant = isLandscape ? 0 : 64
        leftBarWidth.constant = isLandscape ? 64 : 0
        
        topBar.isHidden = isLandscape
        leftBar.isHidden = !isLandscape
        
        setNeedsStatusBarAppearanceUpdate()
        popoverPresentationController?.presentedViewController.dismissVC(completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let popoverPresentationController = segue.destination.popoverPresentationController, let sourceView = sender as? UIView {
            _popoverPresentationController = popoverPresentationController
            popoverPresentationController.sourceRect = sourceView.bounds
        }
    }
}
