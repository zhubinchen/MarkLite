//
//  SettingsViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SideMenu
import SwiftyDropbox

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 48
            tableView.setSeparatorColor(.primary)
        }
    }
    
    let items = [
        ("功能",[
            ("iCloud 同步",#selector(icloud)),
            ("辅助键盘",#selector(assistBar)),
            ]),
        ("外观",[
            ("主题色",#selector(theme)),
            ("渲染样式",#selector(style)),
            ]),
        ("支持一下",[
            ("五星好评",#selector(rate)),
            ("打赏开发者",#selector(donate))
            ]),
        ("反馈",[
            ("问题与意见",#selector(feedback))
            ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "设置"
        navBar?.setBarTintColor(.navBar)
        navBar?.setContentColor(.navBarTint)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settings", for: indexPath)
        let item = items[indexPath.section].1[indexPath.row]
        cell.textLabel?.text = item.0
        cell.textLabel?.setTextColor(.primary)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section].1[indexPath.row]
        perform(item.1)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
}

extension SettingsViewController {
    
    func icloud() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self) { (url) in
                                                        UIApplication.shared.openURL(url)
        }
    }
    
    func rate() {
        UIApplication.shared.openURL(URL(string: rateUrl)!)
    }
    
    func donate() {
        self.view.startLoadingAnimation()
        IAP.requestProducts([donateProductID]) { (response, error) in
            guard let product = response?.products.first else {
                self.view.stopLoadingAnimation()
                return
            }
            IAP.purchaseProduct(product.productIdentifier, handler: { (identifier, error) in
                
                if let err = error {
                    print(err.localizedDescription)
                    self.showAlert(title: "虽然没有打赏成功，还是感谢你的心意")
                    return
                } else {
                    self.showAlert(title: "谢谢你的支持🙏，我会努力做的更好的")
                }
                self.view.stopLoadingAnimation()
            })
        }
    }
    
    func feedback() {
        UIApplication.shared.openURL(URL(string: emailUrl)!)
    }
    
    func assistBar() {
        
    }
    
    func theme() {
        let vc = ThemeViewController()
        pushVC(vc)
    }
    
    func style() {
        let vc = StyleViewController()
        pushVC(vc)
    }
    
}
