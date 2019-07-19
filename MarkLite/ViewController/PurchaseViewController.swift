//
//  PurchaseViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/7/12.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController {
    @IBOutlet weak var subscribeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = /"Premium"
    }
    

    @IBAction func subscribe(_ sender: UIButton!) {
        purchaseProduct(premiumProductID)
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
//            Configure.shared.checkVipAvailable({ (availabel) in
//                if availabel {
//                    self.showAlert(title: /"RestoreSuccess")
//                    self.dismiss(nil)
//                } else {
//                    self.showAlert(title: /"RestoreFailed")
//                }
//                self.view.stopLoadingAnimation()
//            })
            print(identifiers)
        }
    }

    @IBAction func privacy(_ sender: UIButton!) {
        let vc = InfoViewController()
        vc.urlString = "https://www.freeprivacypolicy.com/privacy/view/0c071aa1336dd9e73585f2535466bcf6"
        vc.title = /"Privacy"
        let nav = UINavigationController(rootViewController: vc)
        presentVC(nav)
    }

    @IBAction func terms(_ sender: UIButton!) {
        let vc = InfoViewController()
        vc.urlString = "https://www.freeprivacypolicy.com/privacy/view/0c071aa1336dd9e73585f2535466bcf6"
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
//                Configure.shared.checkVipAvailable({ (availabel) in
//                    if availabel {
//                        self.showAlert(title: /"SubscribedSuccess")
//                        self.dismiss(nil)
//                    } else {
//                        self.showAlert(title: /"SubscribeFailed")
//                    }
//                    self.view.stopLoadingAnimation()
//                })
            })
        }
    }

}
