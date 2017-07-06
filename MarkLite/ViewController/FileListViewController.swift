//
//  FileListViewController.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/22.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions

enum Segue: String {
    case edit
    case next
}

class FileListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 50
            tableView.rowHeight = 50
            tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        }
    }
    @IBOutlet weak var emptyView: UIView!

    fileprivate var sections = [(String,[File])]()

    var root: File! {
        didSet {
            var section = ("",[File]())
            root.children.sorted{$0.0.modifyDate < $0.1.modifyDate}.forEach { (file) in
                if section.0 == file.modifyDate.readableDate().0 {
                    section.1.append(file)
                } else {
                    section = (file.modifyDate.readableDate().0,[file])
                    sections.append(section)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if root == nil {
            root = File(path: localPath)
            title = "全部文件"
            tableView.reloadData()
        } else {
            title = root.name
            navigationItem.leftBarButtonItem = nil
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FileListViewController {
            vc.root = sender as! File
        }
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = sections[indexPath.section].1[indexPath.row]
        if file.type == .text {
            defaultConfigure.currentFile.value = file
        }
        performSegue(withIdentifier: (file.type == .text ? Segue.edit : Segue.next).rawValue, sender: file)
    }
}
