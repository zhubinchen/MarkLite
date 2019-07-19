//
//  UIColor+Extensions.swift
//  WeiBo
//
//  Created by 夜猫子 on 2017/4/2.
//  Copyright © 2017年 夜猫子. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// 颜色的遍历构造器
    ///
    /// - Parameters:
    ///   - red: 红色
    ///   - green: 绿色
    ///   - blue: 蓝色
    /// - Returns: 合成色
    class func cl_rgbColor(red: CGFloat,
                        green: CGFloat,
                        blue: CGFloat) -> UIColor {
        
        let red = red / 255.0
        let green = green / 255.0
        let blue = blue / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    //随机颜色
    class func cl_randomColor () -> UIColor {
        let r = arc4random() % 255
        let g = arc4random() % 255
        let b = arc4random() % 255
        
        let red = CGFloat(r)/255.0
        let green = CGFloat(g)/255.0
        let blue = CGFloat(b)/255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    
    /// 使用十六进制数字生成颜色
    ///
    /// - Parameter hex: hex，格式 0xFFEEDD
    /// - Returns: UIColor
    class func cl_colorWithHex(hex:u_int) -> UIColor {
        
        let red:u_int = u_int((hex & 0xFF0000) >> 16)
        let green:u_int = u_int((hex & 0x00FF00) >> 8)
        let blue:u_int = (u_int(hex & 0x0000FF))
        return cl_rgbColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue))
    }
    
}
