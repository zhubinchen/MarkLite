//
//  OptionsViewController.swift
//  Markdown
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
    let editable: Bool
    let title: String
    let items: [StringConvertible]
    let didSelect: (StringConvertible)->Void
}

extension Theme: StringConvertible {
    var toString: String {
        return displayName
    }
}

extension SplitOption: StringConvertible {
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
    var items: [StringConvertible]!
    let table = UITableView(frame: CGRect(), style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar?.setBarTintColor(.navBar)
        navBar?.setContentColor(.navBarTint)
        
        title = options.title
        items = options.items
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
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.items[indexPath.row].toString
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
        self.options.didSelect(self.items[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.options.editable
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: /"Delete") { [unowned self](_, indexPath) in
            self.showAlert(title: /"DeleteMessage", message: nil, actionTitles: [/"Cancel",/"Delete"], textFieldconfigurationHandler: nil, actionHandler: { (index) in
                if index == 0 {
                    return
                }
                let name = self.items[indexPath.row].toString
                let path = resourcesPath + "/Styles/" + name + ".css"
                try? FileManager.default.removeItem(atPath: path)
                self.items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .middle)
            })
        }
        return [deleteAction]
    }
}
