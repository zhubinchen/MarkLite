//
//  StyleViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/9.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class StyleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var styles: [String]!
    let table = UITableView(frame: CGRect(), style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "渲染样式"
        let path = documentPath + "/style/markdown-style/"

        guard let subPaths = FileManager.default.subpaths(atPath: path) else { return }
        
        styles = subPaths.map{ $0.replacingOccurrences(of: ".css", with: "")}.filter{!$0.hasPrefix(".")}
        
        table.rowHeight = 48
        table.delegate = self
        table.dataSource = self
        table.setSeparatorColor(.primary)
        view.addSubview(table)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        table.frame = self.view.bounds
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return styles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = styles[indexPath.row]
        cell.textLabel?.setTextColor(.primary)
        cell.textLabel?.font = UIFont.font(ofSize: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Configure.shared.markdownStyle.value = styles[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

}
