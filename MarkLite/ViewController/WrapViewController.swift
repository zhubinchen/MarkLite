//
//  WrapViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/2.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift

class WrapViewController: UIViewController {
    
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    @IBOutlet weak var leftBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var leftBar: UIView!
    
    let disposeBag = DisposeBag()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Configure.shared.isLandscape.value ? .default : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Configure.shared.currentFile.value = Configure.shared.root.children.first
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
    }
    
}
