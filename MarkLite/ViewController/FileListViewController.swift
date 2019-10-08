//
//  FileListViewController.swift
//  Markdown
//
//  Created by zhubch on 2017/6/22.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import EZSwiftExtensions
import RxSwift

class FileListViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let tipsLabel = UILabel(frame: CGRect(x: 0, y: 0, w: windowWidth, h: 30))
            tipsLabel.text = "   ".appending(/"SwipeTips")
            tipsLabel.setTextColor(.secondary)
            tipsLabel.font = UIFont.font(ofSize: 14)
            tableView.tableFooterView = tipsLabel
            tableView.setSeparatorColor(.primary)

            let pulldDownLabel = UILabel()
            pulldDownLabel.text = /"ReleaseToRefresh"
            pulldDownLabel.textAlignment = .center
            pulldDownLabel.setTextColor(.secondary)
            pulldDownLabel.font = UIFont.font(ofSize: 14)
            tableView.addPullDownView(pulldDownLabel, bag: bag) { [unowned self] in
                self.refresh()
            }
        }
    }
    
    @IBOutlet weak var emptyView: UIView!
    
    var selectedIndexPath: IndexPath?
    
    fileprivate var childrens = [File]()
    
    var root: File? {
        didSet {
            refresh()
        }
    }
    
    let bag = DisposeBag()
        
    var textField: UITextField?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if title == nil {
            title = root?.name
        }
        
        emptyView.setBackgroundColor(.background)
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        setupUI()
    }
    
    func setupUI() {        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreateMenu(_:)))
        
        navBar?.setTintColor(.tint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.primary)
        tableView.setBackgroundColor(.tableBackground)
        view.setBackgroundColor(.background)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    func refresh() {
        if root == nil {
            childrens = []
        } else {
            childrens = root!.children.sorted{$0.modifyDate > $1.modifyDate}
        }
        if isViewLoaded {
            tableView.reloadData()
        }
    }
    
    
    @objc func showSettings() {
        performSegue(withIdentifier: "menu", sender: nil)
    }
    
    @objc func showCreateMenu(_ sender: Any) {
        showActionSheet(sender: sender, title: nil, message: nil, actionTitles: [/"CreateNote",/"CreateFolder",/"ImportFromFiles"]) { index in
                                if index == 2 {
                self.pickFromFiles()
                return
            }
            guard let file = self.root?.createFile(name: index == 0 ? /"Untitled" : /"UntitledFolder", type: index == 0 ? .text : .folder) else {
                return
            }
            
            self.showAlert(title: /(index == 0 ? "CreateNote" : "CreateFolder"), message: /"RenameTips", actionTitles: [/"Cancel",/"OK"], textFieldconfigurationHandler: { (textField) in
                textField.text = file.name
                self.textField = textField
            }, actionHandler: { (index) in
                if index == 0 {
                    file.trash()
                    return
                }
                self.rename(file: file, newName:self.textField?.text ?? "")
                self.childrens.insert(file, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            })
        }
    }
    
    func rename(file: File, newName: String) {
        let name = newName.trimmed()
        let pattern = "^[^\\.\\*\\:/]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        if predicate.evaluate(with: name) {
            file.rename(to: name)
        } else {
            showAlert(title: /"FileNameError")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FileListViewController,
            let file = sender as? File {
            vc.root = file
            return
        }
        
        if let nav = segue.destination as? UINavigationController,
            let vc = nav.topViewController as? EditViewController,
            let file = sender as? File {
            vc.file = file
            return
        }
        
        if let vc = segue.destination as? EditViewController,
            let file = sender as? File {
            vc.file = file
        }
    }
}

extension FileListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.isHidden = childrens.count == 0
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childrens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "file", for: indexPath) as! FileTableViewCell
        let file = childrens[indexPath.row]
        cell.file = file
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = childrens[indexPath.row]
        if file.type == .folder {
            performSegue(withIdentifier: "next", sender: file)
        } else {
            performSegue(withIdentifier: "edit", sender: file)
        }
        if isPhone {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            if let oldIndexPath = selectedIndexPath {
                childrens[oldIndexPath.row].isSelected = false
                tableView.reloadRows(at: [oldIndexPath], with: .automatic)
            }
            file.isSelected = true
            tableView.reloadRows(at: [indexPath], with: .automatic)
            selectedIndexPath = indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: /"Delete") { [unowned self](_, indexPath) in
            self.showAlert(title: /"DeleteMessage", message: nil, actionTitles: [/"Cancel",/"Delete"], textFieldconfigurationHandler: nil, actionHandler: { (index) in
                if index == 0 {
                    return
                }
                let file = self.childrens[indexPath.row]
                file.trash()
                self.childrens.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .middle)
            })
        }
        let renameAction = UITableViewRowAction(style: .default, title: /"Rename") { [unowned self](_, indexPath) in
            let file = self.childrens[indexPath.row]
            self.showAlert(title: /"Rename", message: /"RenameTips", actionTitles: [/"Cancel",/"OK"], textFieldconfigurationHandler: { (textField) in
                textField.text = file.name
                self.textField = textField
            }, actionHandler: { (index) in
                if index == 0 {
                    return
                }
                self.rename(file: file, newName:self.textField?.text ?? "")
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        renameAction.backgroundColor = .lightGray
        return [deleteAction,renameAction]
    }
}

extension FileListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        rename(file:root!, newName:textField.text ?? "")
        textField.text = root?.name
    }
}

extension FileListViewController: UIDocumentPickerDelegate {
    
//    func pickFromFiles() {
//        let browser = UIDocumentBrowserViewController(forOpeningFilesWithContentTypes: <#T##[String]?#>)
//
//    }
    
    func pickFromFiles() {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        picker.delegate = self
        presentVC(picker)
    }
    
    func didPickFile(_ url: URL) {
        
        let str = (try? String(contentsOf: url)) ?? ""
        if let file = root?.createFile(name: url.deletingPathExtension().lastPathComponent, type: .text) {
            file.text = str
            file.save()
            self.performSegue(withIdentifier: "edit", sender: file)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        didPickFile(url)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
            didPickFile(urls.first!)
        }
    }
}

