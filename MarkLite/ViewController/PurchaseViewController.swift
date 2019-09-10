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
        
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        }
        let date = Date(fromString: "2019-09-15", format: "yyyy-MM-dd")!
        let now = Date()
        if now > date {
            subscribeButton.setTitle(/"SubscribeL", for: .normal)
        }
        MobClick.event("enter_purchase")
    }
    
    @objc func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func subscribe(_ sender: UIButton!) {
        MobClick.event("begin_purchase")
        purchaseProduct(premiumProductID)
    }
    
    @IBAction func restore(_ sender: UIButton!) {
        self.view.startLoadingAnimation()
        MobClick.event("begin_purchase")

        IAP.restorePurchases { (identifiers, error) in
            if let err = error {
                print(err.localizedDescription)
                self.showAlert(title: /"RestoreFailed")
                self.view.stopLoadingAnimation()
                return
            }
            Configure.shared.checkProAvailable({ (availabel) in
                if availabel {
                    MobClick.event("finish_purchase")
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
                        MobClick.event("finish_purchase")
                        self.showAlert(title: /"SubscribedSuccess")
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
