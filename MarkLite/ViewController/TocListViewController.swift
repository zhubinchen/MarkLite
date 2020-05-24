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

class TocListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items = [TOCItem]()
    
    var toc = ""
    
    var textCount = 0
    
    let tableView = UITableView(frame: CGRect.zero)
    
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
        if textCount > 0 {
            title = "\(textCount)" + " " + /"Characters"
        }
        
        parseToc()
        
        setupUI()
        tableView.reloadData()
    }
    
    func setupUI() {
        navBar?.setTintColor(.navTint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.navTitle)
        
        view.setBackgroundColor(.tableBackground)

        tableView.register(BaseTableViewCell.self, forCellReuseIdentifier: "item")
        tableView.rowHeight = 48
        tableView.estimatedRowHeight = 48
        tableView.setSeparatorColor(.primary)
        tableView.setBackgroundColor(.tableBackground)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if items.count == 0 {
            tableView.isHidden = true
            let emptyLabel = UILabel(frame: CGRect.zero)
            emptyLabel.setBackgroundColor(.tableBackground)
            view.addSubview(emptyLabel)
            emptyLabel.setTextColor(.secondary)
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            emptyLabel.text = /"EmptyTableOfContents"
            emptyLabel.snp.makeConstraints { (maker) in
                maker.edges.equalTo(UIEdgeInsetsMake(20, 20, 100, 20))
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! BaseTableViewCell
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.indentationWidth = 10
        return cell
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let item = items[indexPath.row]
        return item.level
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.didSelectTOC(item,fromListVC: self)
    }
}
