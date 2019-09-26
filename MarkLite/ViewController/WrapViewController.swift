//
//  WrapViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/8/2.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift

class WrapViewController: UISplitViewController, UIPopoverPresentationControllerDelegate {
    
//    @IBOutlet weak var emptyView: UIView!
//    @IBOutlet weak var emptyTipsView: UILabel!

    let bag = DisposeBag()
            
    var _popoverPresentationController : UIPopoverPresentationController?
    
    override var popoverPresentationController: UIPopoverPresentationController? {
        return _popoverPresentationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        popoverPresentationController?.delegate = self
        
//        emptyView.setBackgroundColor(.background)
//
//        emptyView.addTapGesture { [unowned self] (_) in
//            self.showFiles(self)
//        }
//
//        Configure.shared.editingFile.asObservable().map{ $0 != nil }.bind(to: emptyView.rx.isHidden).disposed(by: bag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let isLandscape = windowWidth > windowHeight
        Configure.shared.isLandscape.value = isLandscape
                
        popoverPresentationController?.presentedViewController.dismissVC(completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let popoverPresentationController = segue.destination.popoverPresentationController, let sourceView = sender as? UIView {
            _popoverPresentationController = popoverPresentationController
            popoverPresentationController.sourceRect = sourceView.bounds
        }
    }
}
