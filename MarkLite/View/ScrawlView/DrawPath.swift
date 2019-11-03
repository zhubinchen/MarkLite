//
//  DrawPath.swift
//  DupiPlanet
//
//  Created by 乔文德 on 2016/11/16.
//  Copyright © 2016年 team108. All rights reserved.
//

import UIKit

class DrawPath: NSObject {
    var width = CGFloat(2.0)
    var color = UIColor.black
    var path: UIBezierPath?
    var startPoint = CGPoint()
    var endPoint = CGPoint()
    
    //初始化
    class func drawPath(sPoint:CGPoint, width:CGFloat, color:UIColor) -> DrawPath {
        let drawPath = DrawPath();
        drawPath.width = width
        drawPath.color = color
        drawPath.startPoint = sPoint
        drawPath.endPoint = sPoint
        let bezierPath = UIBezierPath()
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round
        bezierPath.lineWidth = width
        bezierPath.move(to: sPoint)
        drawPath.path = bezierPath
        
        return drawPath
    }
    
    //连线
    func pathLineTo(tPoint:CGPoint) {
        self.path?.addLine(to: tPoint);
        
        // set start and end point
        if tPoint.x < self.startPoint.x {self.startPoint.x = tPoint.x}
        if tPoint.y < self.startPoint.y {self.startPoint.y = tPoint.y}
        if tPoint.x > self.endPoint.x {self.endPoint.x = tPoint.x}
        if tPoint.y >  self.endPoint.y {self.endPoint.y = tPoint.y}
    }
    
    //开始绘制
    func draw()  {
        self.color.setStroke()
        self.path?.stroke()
    }
    
    //获取绘制范围
    func getDrawRect() -> (CGPoint, CGPoint) {
        return (CGPoint(x: self.startPoint.x - self.width / 2, y: self.startPoint.y - self.width / 2), CGPoint(x: self.endPoint.x + self.width / 2, y: self.endPoint.y + self.width / 2))
    }
}
