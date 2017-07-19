//
//  NavigationController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/28.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func back(_ sender: UIBarButtonItem) {
        popVC()
    }
    
    func shouldReplacedWith(_ newVc: UIViewController) -> Bool {
        return false
    }
    
    var customNavBar: UIView {
        if let v = self.view.viewWithTag(4654) {
            return v
        }
        let v = UIView(x: 0, y: -64, w: windowWidth, h: 64)
        v.backgroundColor = .white
        v.tag = 4654
        self.view.addSubview(v)
        return v
    }
    
    func showCustomNavBar() {
        navigationController?.navigationBar.subviews.first?.alpha = 0
        setNeedsStatusBarAppearanceUpdate()
        customNavBar.isHidden = false
    }
    
    func hideCustomNavBar() {
        navigationController?.navigationBar.subviews.first?.alpha = 1
        setNeedsStatusBarAppearanceUpdate()
        customNavBar.isHidden = false
    }
}

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(back))
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
    }
    
}

extension NavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
}
