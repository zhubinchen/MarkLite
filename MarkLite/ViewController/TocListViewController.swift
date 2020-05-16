//
//  TocListViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2020/4/15.
//  Copyright © 2020 zhubch. All rights reserved.
//

import UIKit

protocol TocListDelegate: NSObjectProtocol {
    func didSelectTOC(_ toc: TOCItem, fromListVC: TocListViewController)
}

class TocListViewController: UITableViewController {
    
    var items = [TOCItem]()
    
    var toc = ""
    
    weak var delegate: TocListDelegate?
    
    func parseToc() {
        let list = toc.components(separatedBy: "\n")
        var level = 0
        for item in list {
            if item.hasPrefix("<ul") {
                level += 1
            } else if item == "</ul>" {
                level -= 1
            } else if item.hasPrefix("<a href=\"#toc_") {
                let toc = TOCItem()
                toc.level = level - 1
                toc.idx = items.count
                if let range = item.firstMatchRange(">.+</a>"), range.length > 5 {
                    toc.title = item.substring(with:NSRange(location: range.location + 1, length: range.length-5))
                }
                items.append(toc)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = /"TOC"
        
        parseToc()
        

        tableView.reloadData()
    }
    
    func setupUI() {
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        
        tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: "item")
        tableView.rowHeight = 48
        tableView.estimatedRowHeight = 48
        tableView.setSeparatorColor(.primary)
        tableView.setBackgroundColor(.tableBackground)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! BaseTableViewCell
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.indentationWidth = 10
        return cell
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let item = items[indexPath.row]
        return item.level
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.didSelectTOC(item,fromListVC: self)
    }
}
