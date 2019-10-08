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
        tableView.setBackgroundColor(.tableBackground)
        
        tableView.rowHeight = 44
        tableView.estimatedRowHeight = 44
        tableView.sectionHeaderHeight = 0.01
        tableView.sectionFooterHeight = 20
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            downloadCSS()
        }
    }
    
    func downloadCSS() {
        if (nameTextfield.text?.trimmed().length ?? 0) < 1 {
            showAlert(title:/"InvalidStyleName")
            return
        }
        if (urlTextfield.text?.trimmed().length ?? 0) < 1 {
            showAlert(title:/"InvalidStyleURL")
            return
        }
        
        let name = nameTextfield.text?.trimmed() ?? "Custom"
        let destPath = resourcesPath + "/Styles/" + name + ".css"
        if FileManager.default.fileExists(atPath: destPath) {
            self.showAlert(title:"DumplicatedName")
            return
        }

        guard let url = try? urlTextfield.text?.trimmed().asURL() else { return }
        guard url != nil else { return }
        SVProgressHUD.show()
        request(url!).responseData { resp in
            print(resp)
            guard resp.error == nil else {
                self.showAlert(title:resp.error?.localizedDescription ?? "")
                return
            }
            guard let data = resp.data else { return }
            FileManager.default.createFile(atPath: destPath, contents: data, attributes: nil)
            SVProgressHUD.dismiss()
        }
    }
}
