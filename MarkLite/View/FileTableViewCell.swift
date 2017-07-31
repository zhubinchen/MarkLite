//
//  FileTableViewCell.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/22.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SwipeCellKit

class FileTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var selectedMark: UIView!
    
    let selectedMarkView = UIView(hexString: "333333")
    let selectedBg = UIView(hexString: "e0e0e0")
    
    var file: File! {
        didSet {
            nameLabel.text = file.name
            timeLabel.text = file.modifyDate.readableDate().0 + file.modifyDate.readableDate().1
            selectedMark.isHidden = !file.isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedBg.addSubview(selectedMarkView)
        self.selectedBackgroundView = selectedBg
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedBg.frame = CGRect(x: 0, y: 0, w: windowWidth, h: h)
        selectedMarkView.frame = CGRect(x: 0, y: 0, w: 5, h: h)
    }
}
