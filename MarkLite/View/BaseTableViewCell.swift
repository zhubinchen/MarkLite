//
//  BaseTableViewCell.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/9/26.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    override var accessoryType: UITableViewCellAccessoryType {
        didSet {
            if accessoryType == .disclosureIndicator {
                let iconView = UIImageView(image: #imageLiteral(resourceName: "icon_forward"))
                iconView.setTintColor(.secondary)
                accessoryView = iconView
            } else {
                accessoryView = nil
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
 
    func setup() {
        
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        
        let selectedBg = UIView(hexString: "e0e0e0")
        let selectedMark = UIView(hexString: "000000")
        
        selectedBackgroundView = selectedBg
        
        selectedBg.setBackgroundColor(.selectedCell)
        textLabel?.setTextColor(.primary)
        detailTextLabel?.setTextColor(.secondary)
        setBackgroundColor(.background)
        imageView?.setTintColor(.tint)

        selectedMark.setBackgroundColor(.tint)
        selectedBg.addSubview(selectedMark)
        selectedMark.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(4)
        }
        
        if accessoryType == .disclosureIndicator {
            let iconView = UIImageView(image: #imageLiteral(resourceName: "icon_forward"))
            iconView.setTintColor(.secondary)
            accessoryView = iconView
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.indentationLevel > 0 {
            let indentPoints = CGFloat(self.indentationLevel) * self.indentationWidth
            self.contentView.frame = CGRect(x: indentPoints, y: self.contentView.frame.origin.y, w: self.contentView.frame.size.width - indentPoints, h: self.contentView.frame.size.height)
        }
    }

}
