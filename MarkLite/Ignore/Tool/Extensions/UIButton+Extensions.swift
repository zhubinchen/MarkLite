//
//  UIButton+Extensions.swift
//  WeiBo
//
//  Created by 夜猫子 on 2017/4/2.
//  Copyright © 2017年 夜猫子. All rights reserved.
//

import UIKit

extension UIButton {
    
    /// 遍历构造器(创建按钮可以添加点击事件)
    ///
    /// - Parameters:
    ///   - title: 按钮文字
    ///   - titleColor: 文字颜色
    ///   - fontSize: 文字大小
    ///   - image: 图片名字
    ///   - backImage: 背景图片名字
    ///   - target: target
    ///   - action: action
    ///   - event: UIControlEvents
    convenience init(title: String?,
                     titleColor: UIColor = UIColor.darkGray,
                     fontSize: CGFloat = 14,
                     image: String? = nil,
                     backImage: String? = nil,
                     target: AnyObject? = nil,
                     action: Selector? = nil,
                     event: UIControlEvents = .touchUpInside){
        self.init()
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        //传了图片才设置
        if let image = image {
            
            self.setImage(UIImage(named: image), for: .normal)
            self.setImage(UIImage(named: "\(image)_selected"), for: .highlighted)
        }
        //传了图片才设置背景图片
        if let backImage = backImage {
            self.setBackgroundImage(UIImage(named: backImage), for: .normal)
            self.setBackgroundImage(UIImage(named: "\(backImage)_highlighted"), for: .highlighted)
        }
        //添加事件
        if let target = target, let action = action {
            self.addTarget(target, action: action, for: event)
        }
    }
 
}
