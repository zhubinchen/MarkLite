//
//  DrawView.swift
//  DupiPlanet
//
//  Created by 乔文德 on 2016/11/15.
//  Copyright © 2016年 team108. All rights reserved.
//

import UIKit

@objc protocol DrawViewDelegate {
    func didBeginDraw()
}

class DrawView: UIView {
    
    var delegate: DrawViewDelegate?
    var penWidth = CGFloat(2.0)
    var penColor = UIColor.black
    var pathArray = [DrawPath]()
    var tempArray = [DrawPath]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //手势触摸处理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.addTouchPoint(touches: touches, isBegin: true)
        //绘制
        self.setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addTouchPoint(touches: touches, isBegin: false)
        //绘制
        self.setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addTouchPoint(touches: touches, isBegin: false)
        //绘制
        self.setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addTouchPoint(touches: touches, isBegin: false)
        //绘制
        self.setNeedsDisplay()
    }
    
    //add touch point
    func addTouchPoint(touches: Set<UITouch>, isBegin: Bool) {
        let touch:UITouch = (touches as NSSet).anyObject()! as! UITouch
        let point = touch.location(in: self)
        
        if isBegin {
            let path = DrawPath.drawPath(sPoint: point, width: self.penWidth, color: self.penColor)
            self.pathArray.append(path)
            //clear temp
            self.delegate?.didBeginDraw()
            self.tempArray.removeAll()
        }else {
            let path = self.pathArray.last!
            path.pathLineTo(tPoint: point)
        }
    }
    
    //draw rect 
    override func draw(_ rect: CGRect) {
        for path in self.pathArray {
            path.draw()
        }
    }
    
    //back 
    func backToLastStep() -> Bool {
        if self.pathArray.count > 0{
            self.tempArray.append(self.pathArray.removeLast())
        }
        
        self.setNeedsDisplay()
        return self.pathArray.count > 0
    }
    
    //forward
    func forwardNextStep() -> Bool {
        if self.tempArray.count > 0 {
            self.pathArray.append(self.tempArray.removeLast())
        }
        
        self.setNeedsDisplay()
        return self.tempArray.count > 0
    }
    
    //get draw rect
    func getDrawRect() -> CGRect {
        
        var sPoint: CGPoint?
        var ePoint: CGPoint?
        for path in self.pathArray {
            let (start,end) = path.getDrawRect()
    
            if sPoint == nil && ePoint == nil {
                sPoint = start
                ePoint = end
            } else {
                if start.x < sPoint!.x {sPoint!.x = start.x}
                if start.y < sPoint!.y {sPoint!.y = start.y}
                if end.x > ePoint!.x {ePoint!.x = end.x}
                if end.y > ePoint!.y {ePoint!.y = end.y}
            }
        }
        if sPoint == nil && ePoint == nil {
            return CGRect()
        } else {
            return CGRect(x: sPoint!.x, y: sPoint!.y, width: ePoint!.x - sPoint!.x, height: ePoint!.y - sPoint!.y)
        }
    }
    
}

