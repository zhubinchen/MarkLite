//
//  FileListViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/22.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import SwipeCellKit

class FileListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 50
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    @IBOutlet weak var emptyView: UIView!
    
    var editModel = false {
        didSet {
            if editModel {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(finish))
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "全选", style: .plain, target: self, action: #selector(selectAllModel))
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_edit"), style: .plain, target: self, action: #selector(showMenu))
                navigationItem.leftBarButtonItem = menuBarButton
                root.children.forEach{$0.isSelected = false}
                tableView.reloadData()
            }
            tableView.allowsMultipleSelection = editModel
        }
    }
    
    var menuBarButton: UIBarButtonItem?

    fileprivate var sections = [(String,[File])]()

    let root = Configure.shared.root
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "全部文件"
        menuBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_settings"), style: .plain, target: self, action: #selector(showSettings))
        
        editModel = false
        
        loadFiles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadFiles()
    }
    
    func loadFiles() {
        sections = root.children.filter{$0.children.count > 0}.sorted{$0.0.modifyDate < $0.1.modifyDate}.map{($0.name,$0.children)}

        tableView.reloadData()
    }
    
    func showSettings() {
        performSegue(withIdentifier: "menu", sender: nil)
    }
    
    func finish() {
        root.children.filter{$0.isSelected}.forEach{$0.trash()}
        loadFiles()
        editModel = false
    }
    
    func showMenu() {
        MenuView(items: ["新建笔记","批量删除"], postion: CGPoint(x: windowWidth - 140, y: 65 )) { (index) in
            if index == 0 {
                guard let file = self.root.createFile(name: "未命名", type: .text) else { return }
                file.isTemp = true
                Configure.shared.currentFile.value = file
                self.performSegue(withIdentifier: "edit", sender: file)
            } else {
                self.editModel = true
            }
        }.show()
    }
    
    func selectAllModel() {
        root.children.forEach{$0.isSelected = true}
        tableView.reloadData()
    }
    
    func createFile() {
        
    }
}

extension FileListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.isHidden = sections.count == 0
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "file", for: indexPath) as! FileTableViewCell
        cell.file = sections[indexPath.section].1[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(x: 0, y: 0, w: windowWidth, h: 20)
        label.text = "  " + sections[section].0
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = sections[indexPath.section].1[indexPath.row]

        tableView.deselectRow(at: indexPath, animated: true)
        
        if editModel {
            file.isSelected.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        Configure.shared.currentFile.value = file
        performSegue(withIdentifier: "edit", sender: file)
    }
}

extension FileListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left {
            return nil
        }
        let file = sections[indexPath.section].1[indexPath.row]

        let deleteAction = SwipeAction(style: .destructive, title: "删除") { action, indexPath in
            file.trash()
            self.sections[indexPath.section].1.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            if self.sections[indexPath.section].1.count == 0 {
                self.sections.remove(at: indexPath.section)
                self.tableView.deleteSections([indexPath.section], with: .bottom)
            } else {
                self.tableView.deleteRows(at: [indexPath], with: .bottom)
            }
            self.tableView.endUpdates()
        }

        let renameAction = SwipeAction(style: .default, title: "重命名") { action, indexPath in
            
        }
        renameAction.backgroundColor = UIColor(red: 49/255.0, green: 105/255.0, blue: 254/255.0, alpha: 1)

        return [deleteAction,renameAction]
    }
}
