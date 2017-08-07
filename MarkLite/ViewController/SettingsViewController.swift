//
//  SettingsViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SideMenu

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 40
        }
    }
    
    let items = [
        ("功能",[
            ("iCloud 同步",#selector(icloud(_:))),
            ("图床",#selector(picServer)),
            ("辅助键盘",#selector(picServer)),
            ]),
        ("外观",[
            ("主题色",#selector(picServer)),
            ("预览样式",#selector(picServer)),
            ("编辑器字体",#selector(picServer)),
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
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section].1[indexPath.row]
        perform(item.1)
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let label = UILabel(x: 0, y: 0, w: windowWidth, h: 20)
//        label.text = "  " + items[section].0
//        label.textColor = rgb("a0a0a0")
//        label.font = UIFont.font(ofSize: 12)
//        return label
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
}

extension SettingsViewController {
    
    func icloud(_ sender: UISwitch) {
        
    }
    
    func rate() {
        
    }
    
    func donate() {
        
    }
    
    func feedback() {
        
    }
    
    func font() {
        
    }
    
    func style() {
        
    }
    
    func picServer() {
        
    }
}
