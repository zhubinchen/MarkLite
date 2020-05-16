//
//  NavigationViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2020/5/16.
//  Copyright © 2020 zhubch. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }

}
