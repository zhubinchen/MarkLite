//
//  CustomStyleViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/9/11.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit
import Alamofire

class CustomStyleViewController: UITableViewController {
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var urlTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = /"CSS"
        
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        view.setBackgroundColor(.background)
        view.setTintColor(.tint)
        nameTextfield.setTextColor(.primary)
        urlTextfield.setTextColor(.primary)
        nameTextfield.setPlaceholderColor(.secondary)
        urlTextfield.setPlaceholderColor(.secondary)
        tableView.setBackgroundColor(.tableBackground)
    }
    
    @IBAction func downloadCSS() {
        doIfPro {
            self._downloadCSS()
        }
    }
    
    func _downloadCSS() {
        if (nameTextfield.text?.trimmed().length ?? 0) < 1 {
            ActivityIndicator.showError(withStatus: /"InvalidStyleName")
            return
        }
        if (urlTextfield.text?.trimmed().length ?? 0) < 1 {
            ActivityIndicator.showError(withStatus: /"InvalidStyleURL")
            return
        }
        
        let name = nameTextfield.text?.trimmed() ?? "Custom"
        let destPath = resourcesPath + "/Styles/" + name + ".css"
        if FileManager.default.fileExists(atPath: destPath) {
            ActivityIndicator.showError(withStatus: /"DumplicatedName")
            return
        }

        guard let url = try? urlTextfield.text?.trimmed().asURL() else { return }
        guard url != nil else { return }
        ActivityIndicator.show()
        request(url!).responseData { resp in
            print(resp)
            guard resp.error == nil else {
                ActivityIndicator.showError(withStatus: resp.error?.localizedDescription ?? "")
                return
            }
            guard let data = resp.data else { return }
            FileManager.default.createFile(atPath: destPath, contents: data, attributes: nil)
            ActivityIndicator.dismiss()
        }
    }
    
    func doIfPro(_ task: (() -> Void)) {
        if Configure.shared.isPro {
            task()
            return
        }
        showAlert(title: /"PremiumOnly", message: /"PremiumTips", actionTitles: [/"SubscribeNow",/"Cancel"], textFieldconfigurationHandler: nil) { (index) in
            if index == 0 {
                self.premium()
            }
        }
    }
    
    func premium() {
        let sb = UIStoryboard(name: "Settings", bundle: Bundle.main)
        let vc = sb.instantiateVC(PurchaseViewController.self)!
        dismiss(animated: false) {
            let nav = NavigationViewController(rootViewController: vc)
            nav.modalPresentationStyle = .formSheet
            UIApplication.shared.keyWindow?.rootViewController?.presentVC(nav)
        }
    }
}
