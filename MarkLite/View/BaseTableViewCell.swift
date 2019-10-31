//
//  BaseTableViewCell.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/9/26.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit
import SnapKit

class BaseTableViewCell: UITableViewCell {
    
    override var accessoryType: UITableViewCellAccessoryType {
        didSet {
            updateAccessoryView()
        }
    }
    
    var needUnlock: Bool = false {
        didSet {
            updateAccessoryView()
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
        
        let selectedBg = UIView()
        let selectedMark = UIView()
        
        selectedBackgroundView = selectedBg
        
        selectedBg.setBackgroundColor(.selectedCell)
        textLabel?.setTextColor(.primary)
        detailTextLabel?.setTextColor(.secondary)
        setBackgroundColor(.background)
        imageView?.setTintColor(.primary)

        selectedMark.setBackgroundColor(.tint)
        selectedBg.addSubview(selectedMark)
        selectedMark.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(4)
        }
        
        updateAccessoryView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.indentationLevel > 0 {
            let indentPoints = CGFloat(self.indentationLevel) * self.indentationWidth
            self.contentView.frame = CGRect(x: indentPoints, y: self.contentView.frame.origin.y, w: self.contentView.frame.size.width - indentPoints, h: self.contentView.frame.size.height)
        }
    }

    func updateAccessoryView() {
        if accessoryType == .disclosureIndicator {
            let icon = needUnlock ? #imageLiteral(resourceName: "icon_lock") : #imageLiteral(resourceName: "icon_forward")
            let iconView = UIImageView(image: icon)
            iconView.setTintColor(.secondary)
            iconView.tintImage = icon
            accessoryView = iconView
        } else {
            accessoryView = nil
        }
    }
}
