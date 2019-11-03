//
//  NavigationController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/11/2.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.delegate = self
    }
    
//    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
//        impactIfAllow()
//        return true
//    }
}
