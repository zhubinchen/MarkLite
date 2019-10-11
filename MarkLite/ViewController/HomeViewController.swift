//
//  HomeViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/8/2.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift

class HomeViewController: UISplitViewController, UISplitViewControllerDelegate {

    let bag = DisposeBag()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return isPhone
    }
}
