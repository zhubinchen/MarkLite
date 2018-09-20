//
//  OptionsViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/23.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

protocol StringConvertible {
    var toString: String { get }
}

struct OptionsWraper {
    var selectedIndex: Int? = nil
    let title: String
    let items: [StringConvertible]
    let didSelect: (Int)->Void
}

extension Theme: StringConvertible {
    var toString: String {
        return displayName
    }
}

extension String: StringConvertible {
    var toString: String {
        return self
    }
}

class OptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var options: OptionsWraper!
    let table = UITableView(frame: CGRect(), style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = options.title
        
        table.rowHeight = 48
        table.delegate = self
        table.dataSource = self
        table.setSeparatorColor(.primary)
        view.addSubview(table)
        
        table.setBackgroundColor(.tableBackground)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        table.frame = self.view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = options.selectedIndex {
            table.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = options.items[indexPath.row].toString
        cell.textLabel?.setTextColor(.primary)
        cell.textLabel?.font = UIFont.font(ofSize: 16)
        let selectedBg = UIView(x: 0, y: 0, w: view.w, h: 48)
        let selectedMark = UIView(x: 0, y: 0, w: 5, h: 48)
        selectedBg.addSubview(selectedMark)
        
        selectedBg.setBackgroundColor(.selectedCell)
        selectedMark.setBackgroundColor(.primary)
        
        cell.selectedBackgroundView = selectedBg
        
        cell.setBackgroundColor(.background)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.options.didSelect(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
}
