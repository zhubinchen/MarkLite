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
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var selectedMark: UIView!
    
    let selectedBg = UIView(hexString: "000000")
    var file: File! {
        didSet {
            nameLabel.text = file.name
            timeLabel.text = file.modifyDate.readableDate()
            sizeLabel.text = file.type == .folder ? file.children.count.toString + " " + /"Children" : file.size.readabelSize
            selectedMark.isHidden = !file.isSelected
            iconView.image = (file.type == .folder ? #imageLiteral(resourceName: "icon_folder") : #imageLiteral(resourceName: "icon_text")).recolor(color: ColorCenter.shared.primary.value)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedBackgroundView = selectedBg
        
        selectedBg.setBackgroundColor(.selectedCell)
        selectedMark.setBackgroundColor(.tint)
        
        nameLabel.setTextColor(.primary)
        timeLabel.setTextColor(.secondary)
        sizeLabel.setTextColor(.secondary)
        setBackgroundColor(.background)
        iconView.setTintColor(.primary)
    }
}
