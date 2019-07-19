//
//  UILable+Extensions.swift
//  WeiBo
//
//  Created by 夜猫子 on 2017/4/2.
//  Copyright © 2017年 夜猫子. All rights reserved.
//

import UIKit

extension UILabel {
    
    /// UILable遍历构造器
    ///
    /// - Parameters:
    ///   - title: 文字
    ///   - textColor: 文字颜色
    ///   - fontSize: 文字大小
    ///   - numOfLines: 文字行数
    ///   - alignment: 对齐方式
    convenience init(title: String?,
                     textColor: UIColor = UIColor.darkGray,
                     fontSize: CGFloat = 14,
                     numOfLines: Int = 0,
                     alignment: NSTextAlignment = .left){
        
        self.init()
        
        self.text = title
        self.textColor = textColor
        self.font = UIFont(name: "DINCond-Bold", size: fontSize)
        self.numberOfLines = numOfLines
        self.textAlignment = alignment
        
        self.sizeToFit()
        
    }
 
}
