//
//  FileTableViewCell.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/22.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var showCheckButton: Bool = false {
        didSet {
            checkButton.isHidden = !showCheckButton
            layoutIfNeeded()
        }
    }
    
    var file: File! {
        didSet {
            nameLabel.text = file.name
            sizeLabel.text = file.type == .text ? file.size.readabelSize : "子文件: \(file.children.count)"
            accessoryType = .disclosureIndicator
            timeLabel.text = (file.type == .text ? "上次编辑" : "创建于") + file.modifyDate.readableDate().1
        }
    }
    
}
