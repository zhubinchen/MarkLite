//
//  MenuViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SideMenu

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = 40
        }
    }
    
    let items = [
        ("同步",[
            ("UseCloud",#selector(icloud(_:)))]),
        ("功能",[
            ("PicServer",#selector(picServer)),
            ("Font",#selector(font)),
            ("Style",#selector(style))
            ]),
        ("支持一下",[
            ("RateIt",#selector(rate)),
            ("Donate",#selector(donate))
            ]),
        ("问题反馈",[
            ("Feedback",#selector(feedback))
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(x: 0, y: 0, w: windowWidth, h: 20)
        label.text = "  " + items[section].0
        label.textColor = rgb("a0a0a0")
        label.font = UIFont.font(ofSize: 12)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}

extension MenuViewController {
    
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
