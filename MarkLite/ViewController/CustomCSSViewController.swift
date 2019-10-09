//
//  CustomCSSViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/9/11.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit
import Alamofire

class CustomCSSViewController: UITableViewController {
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var urlTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = /"CSS"
        
        navBar?.setTintColor(.tint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.primary)
        view.setBackgroundColor(.background)
        view.setTintColor(.tint)
        nameTextfield.setTextColor(.primary)
        urlTextfield.setTextColor(.primary)
        nameTextfield.setPlaceholderColor(.secondary)
        urlTextfield.setPlaceholderColor(.secondary)
        tableView.setBackgroundColor(.tableBackground)
    }
    
    @IBAction func downloadCSS() {
        if (nameTextfield.text?.trimmed().length ?? 0) < 1 {
            SVProgressHUD.showError(withStatus: /"InvalidStyleName")
            return
        }
        if (urlTextfield.text?.trimmed().length ?? 0) < 1 {
            SVProgressHUD.showError(withStatus: /"InvalidStyleURL")
            return
        }
        
        let name = nameTextfield.text?.trimmed() ?? "Custom"
        let destPath = resourcesPath + "/Styles/" + name + ".css"
        if FileManager.default.fileExists(atPath: destPath) {
            SVProgressHUD.showError(withStatus: /"DumplicatedName")
            return
        }

        guard let url = try? urlTextfield.text?.trimmed().asURL() else { return }
        guard url != nil else { return }
        SVProgressHUD.show()
        request(url!).responseData { resp in
            print(resp)
            guard resp.error == nil else {
                SVProgressHUD.showError(withStatus: resp.error?.localizedDescription ?? "")
                return
            }
            guard let data = resp.data else { return }
            FileManager.default.createFile(atPath: destPath, contents: data, attributes: nil)
            SVProgressHUD.dismiss()
        }
    }
}
