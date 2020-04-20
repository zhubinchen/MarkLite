//
//  PurchaseViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/7/12.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class PurchaseViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var purchaseTipsLabel: UILabel!
    
    @IBOutlet weak var yearlyButton: UIButton!
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var foreverButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!

    var productId: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = /"Premium"

        setupUI()
        MobClick.event("enter_purchase")
        
        if let id = productId {
            MobClick.event("enter_purchase_promote")
            purchaseProduct(id)
        } else {
            selectedType(yearlyButton)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.scrollRectToVisible(purchaseButton.frame.insetBy(dx: 0, dy: -40), animated: true)
    }
    
    func setupUI() {
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        purchaseButton.setBackgroundColor(.tint)
        titleLabel.setTextColor(.primary)
        purchaseTipsLabel.setTextColor(.secondary)
        view.setBackgroundColor(.background)
        view.setTintColor(.tint)
                
        let paragraphStyle = { () -> NSMutableParagraphStyle in
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.lineSpacing = 10
            return paraStyle
        }()
        
        titleLabel.attributedText = NSAttributedString(string: titleLabel.text ?? "", attributes: [NSAttributedString.Key.paragraphStyle : paragraphStyle])
        
        if (navigationController?.viewControllers.count ?? 0) == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        }
    }
    
    @objc func close() {
        impactIfAllow()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectedType(_ sender: UIButton!) {
        impactIfAllow()
        let buttons = [monthlyButton,yearlyButton,foreverButton]
        buttons.forEach { button in
            if button == sender {
                button?.superview?.setBackgroundColor(.selectedCell)
                button?.superview?.viewWithTag(101)?.setBackgroundColor(.tint)
                (button?.superview?.viewWithTag(102) as? UILabel)?.setTextColor(.primary)
            } else {
                button?.superview?.setBackgroundColor(.background)
                button?.superview?.viewWithTag(101)?.setBackgroundColor(.background)
                (button?.superview?.viewWithTag(102) as? UILabel)?.setTextColor(.secondary)
            }
        }
        
        purchaseTipsLabel.text = [/"MonthlyTips",/"YearlyTips",/"ForeverTips"][sender.tag]
        purchaseButton.setTitle([/"PurchaseMonthly",/"PurchaseYearly",/"PurchaseForever"][sender.tag], for: .normal)
        productId = [premiumMonthlyProductID,premiumYearlyProductID,premiumForeverProductID][sender.tag]
    }
    
    @IBAction func purchase(_ sender: UIButton!) {
        impactIfAllow()
        purchaseProduct(productId)
    }
    
    @IBAction func restore(_ sender: UIButton!) {
        impactIfAllow()
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
                    self.dismiss(animated: true, completion: nil)
                } else {
                    SVProgressHUD.showError(withStatus: /"RestoreFailed")
                }
            })
            print(identifiers)
        }
    }
    
    func purchaseProduct(_ identifier: String) {
        let products = [premiumMonthlyProductID,premiumYearlyProductID,premiumForeverProductID]
        guard let index = products.firstIndex(of: identifier) else { return }
        let beginEvents = ["begin_purchase_monthly","begin_purchase_yearly","begin_purchase_forever"]
        let endEvents = ["finish_purchase_monthly","finish_purchase_yearly","finish_purchase_forever"]
        MobClick.event(beginEvents[index])

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
                    SVProgressHUD.showError(withStatus: error?.localizedDescription ?? "")
                    return
                }
                Configure.shared.checkProAvailable({ (availabel) in
                    SVProgressHUD.dismiss()
                    if availabel {
                        MobClick.event(endEvents[index])
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PremiumStatusChanged"), object: nil)
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

    @IBAction func privacy(_ sender: UIButton!) {
        let vc = WebViewController()
        vc.urlString = "http://ivod.site/markdown/privacy.html"
        vc.title = /"Privacy"
        pushVC(vc)
    }

    @IBAction func terms(_ sender: UIButton!) {
        let vc = WebViewController()
        vc.urlString = "http://ivod.site/markdown/terms.html"
        vc.title = /"Terms"
        pushVC(vc)
    }
    
}

//NSString *locality = [NSUserDefaults.standardUserDefaults objectForKey:@"locality"];
//if ([NSUserDefaults.standardUserDefaults boolForKey:@"_has_shown_"] == NO &&
//    locality.length > 0 &&
//    [locality isEqualToString:@"北京市"] == NO &&
//    (arc4random() % 2) == 1 &&
//    NEAppConf.shared.isShow) {
//    inner = NO;
//    url = @"https://dawangde.me/?u=49945261&referer_code=bc87e230cd&v=20200316";
//    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"_has_shown_"];
//}
