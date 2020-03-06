//
//  SettingsViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionLabel: UILabel!

    var textField: UITextField?
    
    let assitBarSwitch = UISwitch()
    let impactFeedbackSwitch = UISwitch()
    let displayOptionSwitch = UISwitch()

    var items: [(String,[(String,String,Selector)])] {
        var section = [
            ("NightMode","",#selector(darkMode)),
            ("Theme","",#selector(theme)),
            ("ImpactFeedback","",#selector(impactFeedback))
            ]
        if isPad {
            section.append(("SplitOptions","",#selector(splitOption)))
        }
        var status: String? = "SubscribeNow"
        if Configure.shared.isPro {
            status = nil
        }

        var items = [
            ("共享",[("FileSharing","",#selector(webdav))]),
            ("外观",section),
            ("功能",[
                ("AssistKeyboard","",#selector(assistBar)),
                ("SortOptions","",#selector(sortOption)),
                ("ShowExtensionName","",#selector(displayOption)),
                ]),
            ("支持一下",[
                ("Contact","",#selector(feedback))
                ])
        ]
        if let statusString = status {
            items.insert(("高级帐户",[("Premium",statusString,#selector(premium))]), at: 0)
        }
        return items;
    }
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = "Markdown v\(Configure.shared.currentVerion ?? "1.7.0")"
        
        self.title = /"Settings"
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        tableView.setBackgroundColor(.tableBackground)
        tableView.setSeparatorColor(.primary)

        assitBarSwitch.setTintColor(.tint)
        displayOptionSwitch.setTintColor(.tint)
        impactFeedbackSwitch.setTintColor(.tint)

        assitBarSwitch.isOn = Configure.shared.isAssistBarEnabled.value
        displayOptionSwitch.isOn = Configure.shared.showExtensionName
        impactFeedbackSwitch.isOn = Configure.shared.impactFeedback

        assitBarSwitch.addTarget(self, action: #selector(assistBar(_:)), for: .valueChanged)
        displayOptionSwitch.addTarget(self, action: #selector(displayOption(_:)), for: .valueChanged)
        impactFeedbackSwitch.addTarget(self, action: #selector(impactFeedback(_:)), for: .valueChanged)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
    }
    
    @objc func close() {
        impactIfAllow()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BaseTableViewCell(style: .value1, reuseIdentifier: nil)

        let item = items[indexPath.section].1[indexPath.row]
        cell.textLabel?.text = /(item.0)
        cell.detailTextLabel?.text = /(item.1)
        cell.needUnlock = item.0 == "FileSharing" && Configure.shared.isPro == false

        if item.0 == "AssistKeyboard" {
            cell.addSubview(assitBarSwitch)
            cell.accessoryType = .none
            assitBarSwitch.snp.makeConstraints { maker in
                maker.centerY.equalToSuperview()
                maker.right.equalToSuperview().offset(-20)
            }
        } else if item.0 == "ShowExtensionName" {
            cell.addSubview(displayOptionSwitch)
            cell.accessoryType = .none
            displayOptionSwitch.snp.makeConstraints { maker in
                maker.centerY.equalToSuperview()
                maker.right.equalToSuperview().offset(-20)
            }
        } else if item.0 == "ImpactFeedback" {
            cell.addSubview(impactFeedbackSwitch)
            cell.accessoryType = .none
            impactFeedbackSwitch.snp.makeConstraints { maker in
                maker.centerY.equalToSuperview()
                maker.right.equalToSuperview().offset(-20)
            }
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[indexPath.section].1[indexPath.row]
        if item.0 == "AssistKeyboard" || item.0 == "ShowExtensionName" || item.0 == "ImpactFeedback" {
            return
        }
        perform(item.2)
        impactIfAllow()
    }
}

extension SettingsViewController {
    
    func doIfPro(_ task: (() -> Void)) {
        if Configure.shared.isPro {
            task()
            return
        }
        showAlert(title: /"PremiumOnly", message: /"PremiumTips", actionTitles: [/"SubscribeNow",/"Cancel"], textFieldconfigurationHandler: nil) { [unowned self](index) in
            if index == 0 {
                self.premium()
            }
        }
    }
    
    @objc func premium() {
        let sb = UIStoryboard(name: "Settings", bundle: Bundle.main)
        let vc = sb.instantiateVC(PurchaseViewController.self)!
        pushVC(vc)
    }
    
    @objc func splitOption() {
        let items = [SplitOption.automatic,.never,.always]
        let index = items.index{ Configure.shared.splitOption.value == $0 }

        let wraper = OptionsWraper(selectedIndex: index, editable: false, title: /"SplitOptions", items: items) {
            Configure.shared.splitOption.value = $0 as! SplitOption
        }
        let vc = OptionsViewController()
        vc.options = wraper
        pushVC(vc)
    }
    
    @objc func sortOption() {
        let items = [SortOption.name,.type,.modifyDate]
        let index = items.index{ Configure.shared.sortOption.value == $0 }

        let wraper = OptionsWraper(selectedIndex: index, editable: false, title: /"SortOptions", items: items) {
            Configure.shared.sortOption.value = $0 as! SortOption
        }
        let vc = OptionsViewController()
        vc.options = wraper
        pushVC(vc)
    }
        
    @objc func feedback() {
        showAlert(title: /"Contact", message: /"ContactMessage", actionTitles: [/"Cancel",/"Email"]) { index in
            if index == 1 {
                UIApplication.shared.open(URL(string: emailUrl)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func darkMode() {
        let items = [DarkModeOption.dark,.light,.system]
        let index = items.index{ Configure.shared.darkOption.value == $0 }

        let wraper = OptionsWraper(selectedIndex: index, editable: false, title: /"NightMode", items: items) {
            Configure.shared.darkOption.value = $0 as! DarkModeOption
        }
        let vc = OptionsViewController()
        vc.options = wraper
        pushVC(vc)
    }
    
    @objc func assistBar(_ sender: UISwitch) {
        Configure.shared.isAssistBarEnabled.value = sender.isOn
    }
    
    @objc func displayOption(_ sender: UISwitch) {
        Configure.shared.showExtensionName = sender.isOn
        NotificationCenter.default.post(name: NSNotification.Name("DisplayOptionChanged"), object: nil)
    }
    
    @objc func impactFeedback(_ sender: UISwitch) {
        Configure.shared.impactFeedback = sender.isOn
    }
    
    @objc func webdav() {
        doIfPro {
            if NetworkReachabilityManager()?.isReachableOnEthernetOrWiFi ?? false {
                self.performSegue(withIdentifier: "webdav", sender: nil)
            } else {
                SVProgressHUD.showError(withStatus: /"ConnectWifiTips")
            }
        }
    }
    
    @objc func theme() {
        let items = [Theme.white,.black,.pink,.green,.blue,.purple,.red]
        let index = items.index{ Configure.shared.theme.value == $0 }

        let wraper = OptionsWraper(selectedIndex: index, editable: false, title: /"Theme", items: items) {
            Configure.shared.theme.value = $0 as! Theme
        }
        let vc = OptionsViewController()
        vc.options = wraper
        pushVC(vc)
    }
}
