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
    
    static var current: FileListViewController?
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 50
            tableView.rowHeight = UITableViewAutomaticDimension
            let pulldDownLabel = UILabel()
            pulldDownLabel.text = /"ReleaseToCreate"
            pulldDownLabel.textAlignment = .center
            pulldDownLabel.setTextColor(.secondary)
            pulldDownLabel.font = UIFont.font(ofSize: 14)
            tableView.addPullDownView(pulldDownLabel, bag: bag) { [unowned self] in
                guard let file = self.root?.createFile(name: /"Untitled", type: .text ) else {
                    return
                }
                file.isBlank = true
                
                self.childrens.insert(file, at: 0)
                Configure.shared.editingFile.value = file
                if isPhone {
                    self.performSegue(withIdentifier: "edit", sender: file)
                }
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
    
    let titleTextField = UITextField(x: 0, y: 0, w: 100, h: 30)
    
    var textField: UITextField?
    
    var isHomePage = false
    
    override var title: String? {
        didSet {
            titleTextField.text = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FileListViewController.current = self
        if root == nil {
            isHomePage = true
            RecievedNewFile.observe(eventBlock: { [weak self] (path) in
                self?.title = /"LocalFile"
                File.loadLocal{
                    let name = path.components(separatedBy: "/").last ?? "Untitled"
                    self?.root = $0
                    self?.showAlert(title: /"ReceivedNewFile" + name)
                }
            })
        }
        
        setupUI()
        loadFiles()
    }
    
    func loadFiles() {
        if isHomePage {
            
            title = /"LocalFile"
            File.loadLocal{ self.root = $0 }
        } else {
            title = root?.name
            navigationItem.titleView = titleTextField
            titleTextField.font = UIFont.font(ofSize: 18)
            titleTextField.textAlignment = .center
            titleTextField.setTextColor(.navBarTint)
            titleTextField.delegate = self
        }
    }
    
    func setupUI() {
        if isPhone && isHomePage {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_settings"), style: .plain, target: self, action: #selector(showSettings))
        }
        
        if isPad {
            navigationController?.delegate = navigationController
            navigationController?.delegate = navigationController
            navigationController?.interactivePopGestureRecognizer?.delegate = navigationController
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreateMenu))
        
        navBar?.setBarTintColor(.navBar)
        navBar?.setContentColor(.navBarTint)
        tableView.setBackgroundColor(.tableBackground)
        view.setBackgroundColor(.background)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if root?.isBlank ?? false {
            titleTextField.becomeFirstResponder()
        }
        
        refresh()
    }
    
    func refresh() {
        if root == nil {
            childrens = []
        } else {
            root?.children.forEach({ (file) in
                
                if file.isBlank {
                    if let value = Configure.shared.editingFile.value,
                        value == file,
                        isPad {
                        return
                    }
                    if Configure.shared.isAutoClearEnabled {
                        file.trash()
                    }
                }
            })
            childrens = root!.children.sorted{$0.modifyDate < $1.modifyDate}
        }
        if isViewLoaded {
            tableView.reloadData()
        }
    }
    
    
    @objc func showSettings() {
        performSegue(withIdentifier: "menu", sender: nil)
    }
    
    @objc func showCreateMenu() {
        MenuView(items: [/"CreateNote",/"CreateFolder",/"ImportFromFiles"],
                 postion: CGPoint(x:view.w - 140,y: isPad ? 44 : 64),
                 textAlignment: .left) { (index) in
                    if index == 2 {
                        self.pickFromFiles()
                        return
                    }
                    guard let file = self.root?.createFile(name: /"Untitled", type: index == 0 ? .text : .folder) else {
                        return
                    }
                    file.isBlank = true
                    
                    self.childrens.insert(file, at: 0)
                    if file.type == .text {
                        Configure.shared.editingFile.value = file
                        if isPhone {
                            self.performSegue(withIdentifier: "edit", sender: file)
                        } else {
                            self.dismissVC(completion: nil)
                        }
                    } else if file.type == .folder {
                        self.performSegue(withIdentifier: "next", sender: file)
                    }
            }.show(on: self.navigationController?.view)
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
        if let vc = segue.destination as? FileListViewController,let file = sender as? File {
            vc.root = file
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
        
        if isPhone {
            tableView.deselectRow(at: indexPath, animated: true)
            if file.type == .folder {
                performSegue(withIdentifier: "next", sender: file)
            } else {
                Configure.shared.editingFile.value = file
                performSegue(withIdentifier: "edit", sender: file)
            }
        } else {
            if let oldIndexPath = selectedIndexPath {
                childrens[oldIndexPath.row].isSelected = false
                tableView.reloadRows(at: [oldIndexPath], with: .automatic)
            }
            file.isSelected = true
            tableView.reloadRows(at: [indexPath], with: .automatic)
            selectedIndexPath = indexPath
            if file.type == .folder {
                performSegue(withIdentifier: "next", sender: file)
            } else {
                Configure.shared.editingFile.value = file
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: /"Delete") { [unowned self](_, indexPath) in
            let file = self.childrens[indexPath.row]
            file.trash()
            self.childrens.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .middle)
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
    
    func pickFromFiles() {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .import)
        picker.delegate = self
        presentVC(picker)
    }
    
    func didPickFile(_ url: URL) {
        let str = (try? String(contentsOf: url)) ?? ""
        if let file = root?.createFile(name: url.lastPathComponent, type: .text) {
            file.write(text: str)
            self.performSegue(withIdentifier: "next", sender: file)
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

