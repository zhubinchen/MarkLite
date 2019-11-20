//
//  NavigationController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/11/2.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UINavigationBarDelegate {
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        impactIfAllow()
        guard #available(iOS 13.0, *) else {
            popViewController(animated: true)
            return true
        }
        return true
    }

    func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem) {

    }
    
}
