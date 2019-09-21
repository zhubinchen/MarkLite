//
//  PurchaseViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/7/12.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController {
    @IBOutlet weak var yearlyButton: UIButton!
    @IBOutlet weak var scrollViewOffsetX: NSLayoutConstraint!
    @IBOutlet weak var scrollViewOffsetY: NSLayoutConstraint!
    @IBOutlet weak var scrollViewOffsetBottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = /"Premium"
        
        if isPad {
            self.scrollViewOffsetX.constant = min(windowWidth, windowHeight) * 0.12
            self.scrollViewOffsetY.constant =  min(windowWidth, windowHeight) * 0.12
            self.scrollViewOffsetBottom.constant =  min(windowWidth, windowHeight) * 0.12
        }
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        }
        let date = Date(fromString: "2019-09-25", format: "yyyy-MM-dd")!
        let now = Date()
        if now > date {
            yearlyButton.setTitle(/"SubscribeL", for: .normal)
        }
        MobClick.event("enter_purchase")
    }
    
    @objc func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func subscribeMonthly(_ sender: UIButton!) {
        MobClick.event("begin_purchase_monthly")
        purchaseProduct(premiumMonthlyProductID)
    }
    
    @IBAction func subscribeYearly(_ sender: UIButton!) {
        MobClick.event("begin_purchase_yearly")
        purchaseProduct(premiumYearlyProductID)
    }
    
    @IBAction func restore(_ sender: UIButton!) {
        self.view.startLoadingAnimation()

        IAP.restorePurchases { (identifiers, error) in
            if let err = error {
                print(err.localizedDescription)
                self.showAlert(title: /"RestoreFailed")
                self.view.stopLoadingAnimation()
                return
            }
            Configure.shared.checkProAvailable({ (availabel) in
                if availabel {
                    self.showAlert(title: /"RestoreSuccess")
                    self.popVC()
                } else {
                    self.showAlert(title: /"RestoreFailed")
                }
                self.view.stopLoadingAnimation()
            })
            print(identifiers)
        }
    }

    @IBAction func privacy(_ sender: UIButton!) {
        let vc = InfoViewController()
        vc.urlString = "https://zhubinchen.github.io/Page/Markdown/privacy.html"
        vc.title = /"Privacy"
        let nav = UINavigationController(rootViewController: vc)
        presentVC(nav)
    }

    @IBAction func terms(_ sender: UIButton!) {
        let vc = InfoViewController()
        vc.urlString = "https://zhubinchen.github.io/Page/Markdown/terms.html"
        vc.title = /"Terms"
        let nav = UINavigationController(rootViewController: vc)
        presentVC(nav)
    }
    
    func purchaseProduct(_ identifier: String) {
        self.view.startLoadingAnimation()
        IAP.requestProducts([identifier]) { (response, error) in
            guard let product = response?.products.first else {
                self.view.stopLoadingAnimation()
                return
            }
            IAP.purchaseProduct(product.productIdentifier, handler: { (identifier, error) in
                if error != nil {
                    self.view.stopLoadingAnimation()
                    print(error?.localizedDescription ?? "")
                    return
                }
                Configure.shared.checkProAvailable({ (availabel) in
                    if availabel {
                        if identifier == premiumYearlyProductID {
                            MobClick.event("finish_purchase_yearly")
                        } else {
                            MobClick.event("finish_purchase_monthly")
                        }
                        self.showAlert(title: /"SubscribeSuccess")
                        self.popVC()
                    } else {
                        self.showAlert(title: /"SubscribeFailed")
                    }
                    self.view.stopLoadingAnimation()
                })
            })
        }
    }

}
