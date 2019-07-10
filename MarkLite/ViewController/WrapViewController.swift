//
//  WrapViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/8/2.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift
import SideMenu

class WrapViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    @IBOutlet weak var leftBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyTipsView: UILabel!

    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var leftBar: UIView!

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var leftTitle: UILabel!

    let bag = DisposeBag()
    
    var editVC: EditViewController?
    
    var filesVC: UISideMenuNavigationController?
    
    var _popoverPresentationController : UIPopoverPresentationController?
    
    override var popoverPresentationController: UIPopoverPresentationController? {
        return _popoverPresentationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Configure.shared.editingFile.asObservable().map{$0?.name ?? ""}.bind(to: topTitle.rx.text).disposed(by: bag)
        Configure.shared.editingFile.asObservable().map{($0?.name ?? "").vertical}.bind(to: leftTitle.rx.text).disposed(by: bag)
        
        popoverPresentationController?.delegate = self
        
        statusBar.setBackgroundColor(.background)
        emptyView.setBackgroundColor(.background)
        emptyTipsView.setTextColor(.navBarTint)
        
        topBar.setBackgroundColor(.navBar)
        leftBar.setBackgroundColor(.navBar)
        topBar.setTintColor(.navBarTint)
        leftBar.setTintColor(.navBarTint)
        topTitle.setTextColor(.navBarTint)
        leftTitle.setTextColor(.navBarTint)
        
        emptyView.addTapGesture { [unowned self] (_) in
            self.showFiles(self)
        }
        
        Configure.shared.editingFile.asObservable().map{ $0 != nil }.bind(to: emptyView.rx.isHidden).disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isMovingToParentViewController {
            showFiles(self)
        }
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
        } else if let nav = segue.destination as? UISideMenuNavigationController {
            filesVC = nav
        }
    }
    
    @IBAction func showFiles(_ sender: Any) {
        if let vc = filesVC {
            presentVC(vc)
        } else {
            performSegue(withIdentifier: "showFiles", sender: sender)
        }
    }
    
    @IBAction func export(_ sender: Any) {
        editVC?.showExportMenu(sender)
    }
}
