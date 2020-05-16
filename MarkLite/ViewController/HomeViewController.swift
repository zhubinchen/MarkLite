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
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.viewControllers.first
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        view.setBackgroundColor(.tableBackground)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if previousTraitCollection == nil
                || traitCollection.userInterfaceStyle == previousTraitCollection!.userInterfaceStyle
                || Configure.shared.darkOption.value != .system {
                return
            }
            if traitCollection.userInterfaceStyle == .dark && Configure.shared.theme.value != .black {
                Configure.shared.theme.value = .black
            } else if traitCollection.userInterfaceStyle == .light && Configure.shared.theme.value == .black {
                Configure.shared.theme.value = .white
            }
        }
    }
    
    public func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
