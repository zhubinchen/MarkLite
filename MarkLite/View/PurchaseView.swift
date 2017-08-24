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
    
    @IBOutlet weak var oldUserView: UIView!
    @IBOutlet weak var premiumUserView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let language = UserDefaults.standard.string(forKey: "AppleLanguages")
        if language == "zh-Hans" && Configure.shared.isOldUser {
            oldUserView.isHidden = false
            premiumUserView.isHidden = false
        } else {
            oldUserView.isHidden = true
            premiumUserView.isHidden = true
        }
    }
    
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
    
    @IBAction func restoreVIP(_ sender: UIButton) {
        self.startLoadingAnimation()

        IAP.restorePurchases { (identifiers, error) in
            if let err = error {
                print(err.localizedDescription)
                self.vc?.showAlert(title: /"RestoreFailed")
                self.stopLoadingAnimation()
                return
            }
            Configure.shared.checkVipAvailable({ (availabel) in
                if availabel {
                    self.vc?.showAlert(title: /"RestoreSuccess")
                    self.dismiss(nil)
                } else {
                    self.vc?.showAlert(title: /"RestoreFailed")
                }
                self.stopLoadingAnimation()
            })
            print(identifiers)
        }
    }
    
    func purchaseProduct(_ identifier: String) {
        self.startLoadingAnimation()
        IAP.requestProducts([identifier]) { (response, error) in
            guard let product = response?.products.first else {
                self.stopLoadingAnimation()
                return
            }
            IAP.purchaseProduct(product.productIdentifier, handler: { (identifier, error) in
                if error != nil {
                    self.stopLoadingAnimation()
                    print(error?.localizedDescription ?? "")
                    return
                }
                Configure.shared.checkVipAvailable({ (availabel) in
                    if availabel {
                        self.vc?.showAlert(title: /"SubscribedSuccess")
                        self.dismiss(nil)
                    } else {
                        self.vc?.showAlert(title: /"SubscribeFailed")
                    }
                    self.stopLoadingAnimation()
                })
            })
        }
    }

    @IBAction func dismiss(_ sender: Any?) {
        if let vc = vc as? SettingsViewController {
            vc.tableView.reloadData()
        }
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
