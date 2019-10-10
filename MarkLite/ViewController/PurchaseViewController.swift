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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = /"Premium"
        
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)

        if self.navigationController?.viewControllers.count == 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        }
        let date = Date(fromString: "2019-10-04", format: "yyyy-MM-dd")!
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
        SVProgressHUD.show()

        IAP.restorePurchases { (identifiers, error) in
            if let err = error {
                SVProgressHUD.dismiss()
                print(err.localizedDescription)
                SVProgressHUD.showError(withStatus: /"RestoreFailed")
                return
            }
            Configure.shared.checkProAvailable({ (availabel) in
                SVProgressHUD.dismiss()
                if availabel {
                    SVProgressHUD.showSuccess(withStatus: /"RestoreSuccess")
                    self.popVC()
                } else {
                    SVProgressHUD.showError(withStatus: /"RestoreFailed")
                }
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
        SVProgressHUD.show()
        IAP.requestProducts([identifier]) { (response, error) in
            guard let product = response?.products.first else {
                SVProgressHUD.dismiss()
                return
            }
            IAP.purchaseProduct(product.productIdentifier, handler: { (identifier, error) in
                if error != nil {
                    SVProgressHUD.dismiss()
                    print(error?.localizedDescription ?? "")
                    return
                }
                Configure.shared.checkProAvailable({ (availabel) in
                    SVProgressHUD.dismiss()
                    if availabel {
                        if identifier == premiumYearlyProductID {
                            MobClick.event("finish_purchase_yearly")
                        } else {
                            MobClick.event("finish_purchase_monthly")
                        }
                        self.dismiss(animated: false, completion: nil)
                        SVProgressHUD.showSuccess(withStatus: /"SubscribeSuccess")
                    } else {
                        MobClick.event("failed_purchase")
                        SVProgressHUD.showError(withStatus: /"SubscribeFailed")
                    }
                })
            })
        }
    }

}
