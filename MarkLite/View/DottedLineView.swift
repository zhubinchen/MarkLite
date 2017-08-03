//
//  DottedLineView.swift
//  MarkLite
//
//  Created by zhubch on 2017/8/3.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit

class DottedLineView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.setLineCap(CGLineCap.square)
        
        let lengths:[CGFloat] = [5,10] // 绘制 跳过 无限循环
        
        context.setStrokeColor(rgb("d0d0d0")!.cgColor)
        context.setLineWidth(1)
        context.setLineDash(phase: 0, lengths: lengths)
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: 0, y: h))
        context.strokePath()
    }

}
