//
//  CLCustomPresentAnnimation.swift
//  转场效果-Swift
//
//  Created by 夜猫子 on 2017/5/15.
//  Copyright © 2017年 夜猫子. All rights reserved.
//自定义模态转场效果

import UIKit

class CLCustomPresentAnnimation: NSObject {
    
    /// 记录属性
    fileprivate var isPresent: Bool?
    
    /// 使用weak防止循环引用
    fileprivate weak var transitionContext:UIViewControllerContextTransitioning?
    
    /// 其实Rect
    fileprivate var startRect:CGRect?
    
    /// 动画时长
    fileprivate var animationTime:TimeInterval?
    
    /// 自定义构造方法
    ///
    /// - Parameters:
    ///   - startRect: 起始的Rect（默认CGRect.zero）
    ///   - animationTime: 动画时长（默认0.5秒）
    init(startRect:CGRect,animationTime:TimeInterval) {
        
        self.startRect = startRect
        self.animationTime = animationTime
        super.init()
    }
    
}


// MARK: - UIViewControllerTransitioningDelegate,谁负责转场与解场代理
extension CLCustomPresentAnnimation:UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self as UIViewControllerAnimatedTransitioning;
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //dismiss
        isPresent = false
        return self as UIViewControllerAnimatedTransitioning
    }
    
}


// MARK: - UIViewControllerAnimatedTransitioning，动画执行细节
extension CLCustomPresentAnnimation:UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard (animationTime == nil) else {
            return animationTime!
        }
        return 0.5
    }
    
    //转场动画真正表演的舞台，负责执行动画
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let contationView:UIView = transitionContext.containerView;
        
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let view:UIView = (isPresent! ? toView : fromView)!
        contationView.addSubview(view)
        animationWithView(view: view)
        self.transitionContext = transitionContext
   
    }

}


// MARK: - CAAnimationDelegate,动画开始结束代理
extension CLCustomPresentAnnimation: CAAnimationDelegate {
    
    /// 动画完成之后解除转场
    ///
    ///   - anim: <#anim description#>
    ///   - flag: <#flag description#>
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //动画完成之后解除转场
        transitionContext?.completeTransition(true)
    }
    
}


extension CLCustomPresentAnnimation {
    
    /// 开始动画
    ///
    /// - Parameter view: view description
    fileprivate func animationWithView(view: UIView) {
        let shapeLayer = CAShapeLayer()
        let startBezierPath:UIBezierPath?
        let endRect: CGRect?
        let endRadius = sqrt(view.bounds.size.width * view.bounds.size.width + view.bounds.size.height * view.bounds.size.height)
        if startRect != nil {
            startBezierPath = UIBezierPath(ovalIn: startRect!)
            endRect = startRect!.insetBy(dx: -endRadius, dy: -endRadius)
        }else {
            startBezierPath = UIBezierPath(ovalIn: CGRect.zero)
            endRect = CGRect.zero.insetBy(dx: -endRadius, dy: -endRadius)
        }
        
        let endPath = UIBezierPath(ovalIn: endRect!)
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.path = startBezierPath?.cgPath
        view.layer.mask = shapeLayer
        animationWithStartPath(startPath: startBezierPath!, endPath: endPath, shapeLayer: shapeLayer)
    }
    
    /// 使用核心动画实现layer图层的动画
    ///
    /// - Parameters:
    ///   - startPath: 开始的贝塞尔
    ///   - endPath: 结束的贝塞尔
    ///   - shapeLayer: 图层
    fileprivate func animationWithStartPath(startPath:UIBezierPath,endPath:UIBezierPath,shapeLayer:CAShapeLayer) {
        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.duration = transitionDuration(using: transitionContext)
        basicAnimation.delegate = self
        if self.isPresent == true {
            basicAnimation.fromValue = startPath.cgPath
            basicAnimation.toValue = endPath.cgPath
        }else {
            basicAnimation.fromValue = endPath.cgPath
            basicAnimation.toValue = startPath.cgPath
        }
        basicAnimation.fillMode = kCAFillModeForwards;
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "basicAnimation")
    }
    
}

