//
//  FileTableViewCell.swift
//  Markdown
//
//  Created by zhubch on 2017/6/22.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import RxSwift

class FileTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var selectedMark: UIView!
    
    let selectedMarkView = UIView(hexString: "000000")
    let selectedBg = UIView(hexString: "000000")
    var file: File! {
        didSet {
            nameLabel.text = file.name
            timeLabel.text = /"LastUpdate" + file.modifyDate.readableDate().0 + " " + file.modifyDate.readableDate().1
            sizeLabel.text = file.type == .folder ? file.children.count.toString + " " + /"Children" : file.size.readabelSize
            selectedMark.isHidden = !file.isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedBackgroundView = selectedBg
        
        selectedBg.setBackgroundColor(.selectedCell)
        selectedMarkView.setBackgroundColor(.primary)
        selectedMark.setBackgroundColor(.primary)
        
        nameLabel.setTextColor(.primary)
        timeLabel.setTextColor(.secondary)
        sizeLabel.setTextColor(.secondary)
        setBackgroundColor(.background)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedBg.frame = CGRect(x: 0, y: 0, w: windowWidth, h: h)
        selectedMarkView.frame = CGRect(x: 0, y: 0, w: 5, h: h)
    }
}
