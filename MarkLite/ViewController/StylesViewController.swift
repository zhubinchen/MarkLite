//
//  StylesViewController.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/12/1.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class StylesViewController: OptionsViewController {
    
    let styles: OptionsWraper? = {
        let path = resourcesPath + "/Styles/"
        
        guard let subPaths = FileManager.default.subpaths(atPath: path) else { return nil }
        
        let items = subPaths.map{ $0.replacingOccurrences(of: ".css", with: "")}.filter{!$0.hasPrefix(".")}.sorted(by: >)
        let index = items.index{ Configure.shared.markdownStyle.value == $0 }
        let wraper = OptionsWraper(selectedIndex: index, editable: true, title: /"Style", items: items) {
            Configure.shared.markdownStyle.value = $0.toString
        }
        return wraper
    }()
    
    let highlight: OptionsWraper? = {
        let path = resourcesPath + "/Highlight/highlight-style/"
        
        guard let subPaths = FileManager.default.subpaths(atPath: path) else { return nil }
        
        let items = subPaths.map{ $0.replacingOccurrences(of: ".css", with: "")}.filter{!$0.hasPrefix(".")}
        let index = items.index{ Configure.shared.highlightStyle.value == $0 }
        let wraper = OptionsWraper(selectedIndex: index, editable: false, title: /"CodeStyle", items: items) {
            Configure.shared.highlightStyle.value = $0.toString
        }
        return wraper
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let segment = UISegmentedControl(items: [/"Style",/"CodeStyle"])
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segment
        
        self.options = styles
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        self.options = sender.selectedSegmentIndex == 0 ? styles : highlight
        self.table.reloadData()
        if let index = options.selectedIndex {
            table.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
        }
    }
}
