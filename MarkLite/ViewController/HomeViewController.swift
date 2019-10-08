//
//  HomeViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/10/7.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    
    var items: [[(String,String,UIImage,Selector)]] {
        let section1 = [
            (/"Local","",#imageLiteral(resourceName: "icon_local"),#selector(loadLocal)),
            (/"Cloud","",#imageLiteral(resourceName: "icon_cloud"),#selector(loadCloud)),
            (/"Inbox","",#imageLiteral(resourceName: "icon_box_empty"),#selector(loadInbox)),
        ]
        let section2 = [
            (/"Favorites","",#imageLiteral(resourceName: "icon_favorites"),#selector(recent)),
            (/"Recents","",#imageLiteral(resourceName: "icon_recents"),#selector(recent)),
        ]
        let section3 = [
            (/"Trash","",#imageLiteral(resourceName: "icon_trash"),#selector(recent)),
        ]
        return [section1,section2,section3]
    }
    
    var local: File?
    var inbox: File?
    var cloud: File?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
        setupUI()
        title = /"Documents"
    }
    
    func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_settings"), style: .plain, target: self, action: #selector(showSettings))
                
        navBar?.setTintColor(.tint)
        navBar?.setBackgroundColor(.navBar)
        navBar?.setTitleColor(.primary)
        view.setBackgroundColor(.background)
        tableView.setBackgroundColor(.tableBackground)
        tableView.setSeparatorColor(.primary)
    }
    
    @objc func showSettings() {
        performSegue(withIdentifier: "settings", sender: nil)
    }
    
    @objc func loadLocal() {
        if let root = local {
            self.performSegue(withIdentifier: "file", sender: root)
            return
        }
        File.loadLocal { local in
            if let root = local {
                self.local = root
                self.performSegue(withIdentifier: "file", sender: root)
            }
        }
    }
    
    @objc func loadCloud() {
        if let root = cloud {
            self.performSegue(withIdentifier: "file", sender: root)
            return
        }
        File.loadCloud { cloud in
            if let root = cloud {
                self.cloud = root
                self.performSegue(withIdentifier: "file", sender: root)
            }
        }
    }
    
    @objc func loadInbox() {
        if let root = inbox {
            self.performSegue(withIdentifier: "file", sender: root)
            return
        }
        File.loadInbox { inbox in
            if let root = inbox {
                self.inbox = root
                self.performSegue(withIdentifier: "file", sender: root)
            }
        }
    }
    
    @objc func recent() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let filesVC = segue.destination as? FileListViewController, let file = sender as? File {
            filesVC.root = file
            filesVC.title = file.displayName ?? file.name
        }
    }
}

extension HomeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = item.0
        cell.detailTextLabel?.text = item.1
        cell.imageView?.image = item.2
        cell.imageView?.setTintColor(.tint)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section][indexPath.row]
        self.perform(item.3)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
