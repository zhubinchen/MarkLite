//
//  NavigationController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/28.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SideMenu

extension UIViewController {
    
    func shouldReplacedWith(_ newVc: UIViewController) -> Bool {
        return false
    }
    
    func shouldBack() -> Bool {
        return true
    }
}

class NavigationController: UINavigationController {
    
    var isPoping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.navigationBar.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        if isPoping {
            return nil
        }
        isPoping = true
        
        //FIXME: 这样不好
        Timer.runThisAfterDelay(seconds: 0.01) {
            self.isPoping = false
        }
        return super.popViewController(animated: true)
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}

extension UINavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
    }
    
}

extension UINavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let vc = self.topViewController else {
            return false
        }
        return viewControllers.count > 1 && vc.shouldBack()
    }
    
}

extension UINavigationController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {

        guard let vc = self.topViewController else {
            return false
        }
        if(vc.shouldBack()) {
            popViewController(animated: true)
            return true
        } else {
            for v in navigationBar.subviews {
                if v.alpha > 0 && v.alpha < 1 {
                    UIView.animate(withDuration: 0.25, animations: {
                        v.alpha = 1
                    })
                }
            }
            return false
        }
    }
}
