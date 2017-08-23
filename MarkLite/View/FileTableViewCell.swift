//
//  FileTableViewCell.swift
//  MarkLite
//
//  Created by zhubch on 2017/6/22.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import SwipeCellKit
import RxSwift

class FileTableViewCell: SwipeTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var selectedMark: UIView!
    
    let selectedMarkView = UIView(hexString: "333333")
    let selectedBg = UIView(hexString: "e0e0e0")
    let disposeBag = DisposeBag()
    var file: File! {
        didSet {
            nameLabel.text = file.name
            timeLabel.text = /"LastUpdate" + file.modifyDate.readableDate().0 + " " + file.modifyDate.readableDate().1
            sizeLabel.text = file.type == .folder ? file.children.count.toString + " " + /"Children" : "\(file.size) B"
            selectedMark.isHidden = !file.isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Configure.shared.theme.asObservable().subscribe(onNext: { [unowned self] (theme) in
            self.selectedBg.backgroundColor = theme == .black ? rgb("151515") : rgb("e0e0e0")
        }).addDisposableTo(disposeBag)
        selectedBg.addSubview(selectedMarkView)
        self.selectedBackgroundView = selectedBg
        
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
