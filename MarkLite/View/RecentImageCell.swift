//
//  RecentImageCell.swift
//  Markdown
//
//  Created by 朱炳程 on 2019/11/11.
//  Copyright © 2019 zhubch. All rights reserved.
//

import UIKit

class RecentImageCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let v = UIImageView()
        v.cornerRadius = 2
        v.contentMode = .scaleAspectFill
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.top.left.equalTo(0)
            maker.bottom.right.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
