//
//  PurchaseView.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/17.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class PurchaseView: UIView {
    
    weak var vc: UIViewController?
    
    @IBAction func subscribeMonthlyVIP(_ sender: UIButton) {
        purchaseProduct(monthlyVIPProductID)
    }
    
    @IBAction func subscribeAnnualVIP(_ sender: UIButton) {
        purchaseProduct(annualVIPProductID)
    }
    
    @IBAction func oldUserAnnualVIP(_ sender: UIButton) {
        purchaseProduct(oldUserVIPProductID)
    }
    
    @IBAction func premiumUserAnnualVIP(_ sender: UIButton) {

    }
    
    func purchaseProduct(_ identifier: String) {
        self.startLoadingAnimation()
        IAP.requestProducts([identifier]) { (response, error) in
            guard let product = response?.products.first else {
                self.stopLoadingAnimation()
                return
            }
            IAP.purchaseProduct(product.productIdentifier, handler: { (identifier, error) in
                
                Configure.shared.checkVipAvailable({ (availabel) in
                    if availabel {
                        self.vc?.showAlert(title: "已成功升级到高级帐户！")
                        self.dismiss(nil)
                    } else {
                        self.vc?.showAlert(title: "没有完成订阅😢")
                    }
                    self.stopLoadingAnimation()
                })
            })
        }
    }

    @IBAction func dismiss(_ sender: Any?) {
        removeFromSuperview()
    }
    
    class func showWithViewController(_ vc: UIViewController) {
        guard let win = UIApplication.shared.keyWindow else {
            return
        }
        
        win.viewWithTag(437544)?.removeFromSuperview()
        
        let v: PurchaseView = Bundle.loadNib("PurchaseView")!
        
        v.frame = win.bounds
        v.tag = 437544
        v.vc = vc
        win.addSubview(v)
    }

}
