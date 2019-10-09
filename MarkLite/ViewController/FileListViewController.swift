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
        
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var oprationViewBottom: NSLayoutConstraint!

    let pulldDownLabel = UILabel()
        
    fileprivate var files = [File]()
    
    fileprivate var items = [
        (/"Cloud","",#imageLiteral(resourceName: "icon_cloud"),#selector(goCloud)),
        (/"Inbox","",#imageLiteral(resourceName: "icon_box"),#selector(goInbox)),
    ]
    
    var root: File?
    
    let bag = DisposeBag()
        
    var textField: UITextField?
    
    var isHomePage = false
    
    var selectFolderMode = false
    
    var selectFiles = [File]()
    
    var selectedFolder: File?
    
    var filesToMove: [File]?

    var moveFrom: FileListViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if root == nil || selectFolderMode {
            isHomePage = true
        }
        
        if isHomePage {
            title = /"Documents"
            _ = Configure.shared.theme.asObservable().subscribe(onNext: { (theme) in
                self.navBar?.barStyle = theme == .black ? .black : .default
            })
        } else {
            title = root?.displayName ?? root?.name
            tableView.tableHeaderView = UIView(x: 0, y: 0, w: 0, h: 0.01)
        }
        
        if isHomePage && selectFolderMode == false {
            loadFiles()
        }
        
        refresh()

        setupUI()
        
        setupBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isMovingToParentViewController {
            refresh()
        }
    }
    
    func loadFiles() {
        File.loadInbox { inbox in
            File.inbox = inbox
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        }
        File.loadCloud { cloud in
            File.cloud = cloud
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        File.loadLocal { local in
            File.local = local
            self.root = local
            self.refresh()
        }
    }
    
    @objc func multipleSelect() {
        tableView.setEditing(tableView.isEditing == false, animated: true)
        setupBarButton()
        var inset = CGFloat(0)
        if #available(iOS 11.0, *) {
            inset = view.safeAreaInsets.bottom
        }
        oprationViewBottom.constant = tableView.isEditing ? 0 : -44 - inset
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func selectAllFiles() {
        for i in 0..<files.count {
            let indexPath = IndexPath(row: i, section: isHomePage ? 1 : 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }

    @objc func goCloud() {
        if let root = File.cloud {
            self.performSegue(withIdentifier: "file", sender: root)
            return
        }
        File.loadCloud { cloud in
            if let root = cloud {
                File.cloud = root
                self.performSegue(withIdentifier: "file", sender: root)
            }
        }
    }
    
    @objc func goInbox() {
        if let root = File.inbox {
            self.performSegue(withIdentifier: "file", sender: root)
            return
        }
        File.loadInbox { inbox in
            if let root = inbox {
                File.inbox = root
                self.performSegue(withIdentifier: "file", sender: root)
            }
        }
    }
    
    func refresh() {
        if root == nil {
            files = []
        } else if (selectFolderMode) {
            files = [root!]
        } else {
            files = root!.children.sorted {
                switch Configure.shared.sortOption {
                case .type:
                    return $0.type == .text && $1.type == .folder
                case .name:
                    return $0.name > $1.name
                case .modifyDate:
                    return $0.modifyDate > $1.modifyDate
                }
            }
        }
        if isViewLoaded {
            tableView.reloadData()
        }
    }
    
    @IBAction func moveFiles() {
        self.performSegue(withIdentifier: "move", sender: self.selectFiles)
        multipleSelect()
    }
    
    @IBAction func deleteFiles() {
        self.showAlert(title: /"DeleteMessage", message: nil, actionTitles: [/"Cancel",/"Delete"], textFieldconfigurationHandler: nil, actionHandler: { (index) in
            if index == 0 {
                return
            }
            self.selectFiles.forEach { file in
                file.trash()
            }
            self.refresh()
            self.multipleSelect()
        })
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sureMove() {
        guard let newParent = selectedFolder else { return }
        filesToMove?.forEach {
            $0.move(to: newParent)
        }
        moveFrom?.refresh()
        dismiss(animated: true) {
        }
    }
    
    @objc func showSettings() {
        performSegue(withIdentifier: "settings", sender: nil)
    }
    
    @objc func showCreateMenu(_ sender: Any) {
        showActionSheet(sender: sender, title: nil, message: nil, actionTitles: [/"CreateNote",/"CreateFolder",/"ImportFromFiles",/"MultipleSelect"]) { index in
            if index == 2 {
                self.pickFromFiles()
                return
            }
            if index == 3 {
                self.multipleSelect()
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
                self.files.insert(file, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: self.isHomePage ? 1 : 0)], with: .automatic)
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
            SVProgressHUD.showError(withStatus: /"FileNameError")
        }
    }
    
    func openFile(_ indexPath: IndexPath) {
        if isHomePage && indexPath.section == 0 {
            let item = items[indexPath.row]
            self.perform(item.3)
        } else {
            let file = files[indexPath.row]
            if file.type == .folder {
                performSegue(withIdentifier: "file", sender: file)
            } else {
                performSegue(withIdentifier: "edit", sender: file)
            }
        }
    }
    
    func selectFolder(_ indexPath: IndexPath) {
        if isHomePage && indexPath.section == 0 {
            if indexPath.row == 0 {
                selectedFolder = File.cloud
            } else if indexPath.row == 1 {
                selectedFolder = File.inbox
            }
        } else {
            let file = files[indexPath.row]
            selectedFolder = file
            let cell = tableView.cellForRow(at: indexPath)
            if file.folders.count > 0 {
                var indexPaths = [IndexPath]()
                for i in 1...file.folders.count {
                    indexPaths.append(IndexPath(row: indexPath.row + i, section: indexPath.section))
                }
                if file.expand {
                    files.removeAll { item -> Bool in
                        return file.folders.contains{ $0 == item }
                    }
                    tableView.deleteRows(at: indexPaths, with: .top)
                } else {
                    files.insert(contentsOf: file.folders, at: indexPath.row + 1)
                    tableView.insertRows(at: indexPaths, with: .bottom)
                }
                file.expand = !file.expand
                (cell?.accessoryView as? UIImageView)?.image = (file.expand ?  #imageLiteral(resourceName: "icon_expand") : #imageLiteral(resourceName: "icon_forward")).recolor(color: ColorCenter.shared.secondary.value)
            }
        }
    }
    
    func setupBarButton() {
        if tableView.isEditing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(multipleSelect))
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: /"SelectAll", style: .plain, target: self, action: #selector(selectAllFiles))
        } else if selectFolderMode {
            navigationItem.prompt = /"SelectFolderToMove"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: /"Move", style: .done, target: self, action: #selector(sureMove))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(showCreateMenu(_:)))

            if isHomePage {
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_settings"), style: .plain, target: self, action: #selector(showSettings))
            }
        }
    }
    
    func setupUI() {
        var inset = CGFloat(0)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
            inset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }
        oprationViewBottom.constant = -44 - inset
                                
        navBar?.setTintColor(.tint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.primary)
        view.setBackgroundColor(.background)
        view.setTintColor(.tint)
        tableView.setBackgroundColor(.tableBackground)
        tableView.setSeparatorColor(.primary)
        emptyView.setBackgroundColor(.background)

        pulldDownLabel.text = Configure.shared.sortOption.next.displayName
        pulldDownLabel.textAlignment = .center
        pulldDownLabel.setTextColor(.secondary)
        pulldDownLabel.font = UIFont.font(ofSize: 14)
        tableView.addPullDownView(pulldDownLabel, bag: bag) { [unowned self] in
            Configure.shared.sortOption = Configure.shared.sortOption.next
            self.pulldDownLabel.text = Configure.shared.sortOption.next.displayName
            self.refresh()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "move" {
            if let nav = segue.destination as? UINavigationController,
                let vc = nav.topViewController as? FileListViewController,
                let files = sender as? [File] {
                vc.selectFolderMode = true
                vc.filesToMove = files
                vc.moveFrom = self
                vc.root = File.local
            }
            return
        }
        
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
    }
}

extension FileListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isHomePage {
            return 2
        }
        tableView.isHidden = files.count == 0
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isHomePage && section == 0 {
            return items.count
        }
        return files.count
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if !selectFolderMode {
            return 0
        }
        if isHomePage && indexPath.section == 0 {
            return 0
        }
        let file = files[indexPath.row]
        return file.deep
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)
        if isHomePage && indexPath.section == 0 {
            let item = items[indexPath.row]
            cell.textLabel?.text = item.0
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = "\(File.cloud?.children.count ?? 0) " + /"Children"
            } else {
                cell.detailTextLabel?.text = "\(File.inbox?.children.count ?? 0) " + /"Children"
            }
            cell.imageView?.image = item.2.recolor(color: ColorCenter.shared.tint.value)
            return cell
        } else {
            let file = files[indexPath.row]
            cell.textLabel?.text = file.displayName ?? file.name
            if file.type == .folder {
                cell.detailTextLabel?.text = "\(file.children.count) " + /"Children"
            } else {
                cell.detailTextLabel?.text = file.modifyDate.readableDate()
            }
            cell.imageView?.image = (file.type == .folder ? #imageLiteral(resourceName: "icon_folder") : #imageLiteral(resourceName: "icon_text")).recolor(color: ColorCenter.shared.tint.value)
        }
        if selectFolderMode {
            cell.indentationWidth = 20
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if isHomePage && indexPath.section == 0 {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                return
            } else {
                let file = files[indexPath.row]
                selectFiles.append(file)
            }
        } else if selectFolderMode {
            selectFolder(indexPath)
        } else {
            openFile(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if isHomePage && indexPath.section == 0 {
                return
            }
            let file = files[indexPath.row]
            selectFiles.removeAll { file == $0 }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if selectFolderMode {
            return false
        }
        if isHomePage && indexPath.section == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: /"Delete") { [unowned self](_, indexPath) in
            self.showAlert(title: /"DeleteMessage", message: nil, actionTitles: [/"Cancel",/"Delete"], textFieldconfigurationHandler: nil, actionHandler: { (index) in
                if index == 0 {
                    return
                }
                let file = self.files[indexPath.row]
                file.trash()
                self.files.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .middle)
            })
        }
        let renameAction = UITableViewRowAction(style: .default, title: /"Rename") { [unowned self](_, indexPath) in
            let file = self.files[indexPath.row]
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
        
        let moveAction = UITableViewRowAction(style: .default, title: /"Move") { [unowned self](_, indexPath) in
            self.performSegue(withIdentifier: "move", sender: [self.files[indexPath.row]])
        }
        
        renameAction.backgroundColor = .lightGray
        moveAction.backgroundColor = .orange
        return [deleteAction,renameAction,moveAction]
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

