//
//  MenuView.swift
//  WePost
//
//  Created by zhubch on 16/03/2017.
//  Copyright © 2017 happyiterating. All rights reserved.
//

import UIKit

private let cellHeight: CGFloat = 40

class MenuView: UIView {
    
    fileprivate var items: [(String,Bool)] = []
    
    fileprivate lazy var tableView: UITableView = {
        let table = UITableView(frame: self.bounds, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        self.addSubview(table)
        return table
    }()
    
    var selectedChanged: ((Int) -> Void)?
    
    var dismissed: (() -> Void)?
    
    var textAlignment: NSTextAlignment
    
    init(items: [(String,Bool)],
         postion: CGPoint,
         textAlignment: NSTextAlignment = .left,
         selectedChanged: @escaping (Int) -> Void) {
        self.items = items
        self.textAlignment = textAlignment
        self.selectedChanged = selectedChanged
        super.init(frame: CGRect(x: postion.x, y: postion.y, width: 140, height: CGFloat(items.count) * cellHeight - 1))
        self.tableView.setBackgroundColor(.tableBackground)
        self.tableView.setSeparatorColor(.primary)
        self.cornerRadius = 4
    }
    
    func show(on view: UIView? = nil) {
        
        guard let superView = view ?? UIApplication.shared.keyWindow else {
            return
        }
        let control = UIControl(superView: superView, padding: 0)
        control.backgroundColor = UIColor(white: 0, alpha: 0.1)
        control.addTarget(self, action: #selector(dismiss(sender:)), for: .touchDown)
        control.addSubview(self)
        
        superView.addSubview(control)
        superView.isUserInteractionEnabled = true
        
        self.tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func dismiss(sender: UIControl!){
        dismissed?()
        sender.removeFromSuperview()
    }
    
}

extension MenuView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BaseTableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = items[indexPath.row].0
        cell.textLabel?.textAlignment = textAlignment
        cell.accessoryType = .none
        if items[indexPath.row].1 {
            cell.accessoryType = .disclosureIndicator
            cell.needUnlock = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChanged?(indexPath.row)
        dismissed?()
        self.superview?.removeFromSuperview()
    }
}
