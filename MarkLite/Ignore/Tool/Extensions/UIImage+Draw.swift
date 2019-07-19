//
//  UIImage+Draw.swift
//  WeiBo
//
//  Created by 夜猫子 on 2017/4/2.
//  Copyright © 2017年 夜猫子. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 绘制tabBar上面那根线的效果
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 绘制的大小
    /// - Returns: image
    class func cl_pureImage(color: UIColor = UIColor.white,
                         size: CGSize = CGSize(width: 1,
                         height: 1)) -> UIImage? {
        
        //开始图形上下文
        UIGraphicsBeginImageContext(size)
        //设置颜色
        color.setFill()
        //颜色填充
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        //图形上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// 把图片画成圆形,绘制,对性能更好
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 大小
    ///   - callBack: 回调
    func cl_createCircleImage(color: UIColor = UIColor.white, size: CGSize = CGSize(width: 1, height: 1), callBack:@escaping (UIImage?)->()) {
        
        DispatchQueue.global().async {
            let rect = CGRect(origin: CGPoint.zero, size: size)
            
            //1. 开始图形上下文
            UIGraphicsBeginImageContext(size)
            
            //2. 设置颜色
            color.setFill()
            
            //3. 颜色填充
            UIRectFill(rect)
            
            //圆形裁切
            let path = UIBezierPath(ovalIn: rect)
            path.addClip()
            
            self.draw(in: rect)
            
            //4. 从图形上下文获取图片
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            //5. 关闭图形上下文
            UIGraphicsEndImageContext()
            
            //在主线程更新UI
            DispatchQueue.main.async {
                callBack(image)
            }
        }
 
    }
    
    /// 绘制一张图片，可以解决内存暴涨，并且保持相对较好的质量
    ///
    /// - Parameters:
    ///   - color: color
    ///   - size: size
    ///   - callBack: callBack
    func cl_resizeImage(color: UIColor = UIColor.white, size: CGSize = CGSize(width: 1, height: 1), callBack:@escaping (UIImage?)->()) {
        
        DispatchQueue.global().async {
            let rect = CGRect(origin: CGPoint.zero, size: size)
            
            //1. 开始图形上下文
            UIGraphicsBeginImageContext(size)
            
            //2. 设置颜色
            color.setFill()
            
            //3. 颜色填充
            UIRectFill(rect)
            
            self.draw(in: rect)
            
            //4. 从图形上下文获取图片
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            //5. 关闭图形上下文
            UIGraphicsEndImageContext()
            
            //在主线程更新UI
            DispatchQueue.main.async {
                callBack(image)
            }
        }
    }

    
}
