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
import RxSwift

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 48
            tableView.setSeparatorColor(.primary)
        }
    }
    
    let themeSwitch = UISwitch(x: 0, y: 9, w: 60, h: 60)
    let assitBarSwitch = UISwitch(x: 0, y: 9, w: 60, h: 60)
    
    let items = [
        ("功能",[
            ("升级到高级帐户",#selector(purchase)),
            ("辅助键盘",#selector(assistBar)),
            ]),
        ("外观",[
            ("夜间模式",#selector(night)),
            ("主题色",#selector(theme)),
            ("渲染样式",#selector(style)),
            ]),
        ("支持一下",[
            ("五星好评",#selector(rate)),
            ("问题与意见",#selector(feedback))
            ])
    ]
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "设置"
        navBar?.setBarTintColor(.navBar)
        navBar?.setContentColor(.navBarTint)
        themeSwitch.setTintColor(.navBarTint)
        assitBarSwitch.setTintColor(.navBarTint)
        tableView.setBackgroundColor(.tableBackground)

        themeSwitch.isOn = Configure.shared.theme.value == .black
        assitBarSwitch.isOn = Configure.shared.isAssistBarEnabled.value
        
        themeSwitch.addTarget(self, action: #selector(night(_:)), for: .valueChanged)
        assitBarSwitch.addTarget(self, action: #selector(assistBar(_:)), for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        themeSwitch.x = view.w - 60
        assitBarSwitch.x = view.w - 60
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
        cell.setBackgroundColor(.background)
        
        if item.0 == "辅助键盘" {
            cell.addSubview(assitBarSwitch)
            cell.accessoryType = .none
        }
        if item.0 == "夜间模式" {
            cell.addSubview(themeSwitch)
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[indexPath.section].1[indexPath.row]
        if item.0 == "辅助键盘" || item.0 == "夜间模式" {
            return
        }
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
    
    func purchase() {
        PurchaseView.showWithViewController(self)
    }
    
    func rate() {
        UIApplication.shared.openURL(URL(string: rateUrl)!)
    }
    
    func feedback() {
        UIApplication.shared.openURL(URL(string: emailUrl)!)
    }
    
    func night(_ sender: UISwitch) {
        Configure.shared.theme.value = sender.isOn ? .black : .white
    }
    
    func assistBar(_ sender: UISwitch) {
        Configure.shared.isAssistBarEnabled.value = sender.isOn
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
