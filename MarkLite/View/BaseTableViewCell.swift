//
//  BaseTableViewCell.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/9/26.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    let selectedBg = UIView(hexString: "e0e0e0")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedBackgroundView = selectedBg
        
        selectedBg.setBackgroundColor(.selectedCell)
        textLabel?.setTextColor(.primary)
        detailTextLabel?.setTextColor(.secondary)
        setBackgroundColor(.background)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()        
    }
}
