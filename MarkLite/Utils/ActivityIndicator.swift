//
//  UIView+Loading.swift
//  Markdown
//
//  Created by 朱炳程 on 2020/5/13.
//  Copyright © 2020 zhubch. All rights reserved.
//

import UIKit

class ActivityIndicator {
    
    var inticators = [UIView]()
    var toast: UIView?

    static let shared = ActivityIndicator()
    
    class func showError(withStatus: String?) {
        showMessage(message: withStatus)
    }
    
    class func showSuccess(withStatus: String?) {
        showMessage(message: withStatus)
    }
    
    class func showMessage(message: String?) {
        guard let v = UIApplication.shared.keyWindow else { return }
        ActivityIndicator.shared.toast?.removeFromSuperview()
        let bg = UIView()
        ActivityIndicator.shared.toast = bg
        bg.setBackgroundColor(.primary)
        bg.cornerRadius = 8
        v.addSubview(bg)
        bg.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.lessThanOrEqualToSuperview().multipliedBy(0.8)
            maker.height.greaterThanOrEqualTo(30)
        }
        
        let label = UILabel()
        label.text = message
        label.setTextColor(.background)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        bg.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(10)
            maker.left.equalToSuperview().offset(10)
            maker.right.equalToSuperview().offset(-10)
            maker.bottom.equalToSuperview().offset(-10)
        }
        
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveLinear, animations: {
            bg.alpha = 0
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            ActivityIndicator.shared.toast?.removeFromSuperview()
        }
    }
    
    class func show(on parent: UIView? = UIApplication.shared.keyWindow) {
        guard let v = parent else { return }
        let container = UIView()
        container.isHidden = true
        v.addSubview(container)
        container.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        let loadingView = UIView()
        let size = CGSize(width: 30, height: 30)
        container.addSubview(loadingView)
        loadingView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.size.equalTo(size)
        }
        
        if v == UIApplication.shared.keyWindow {
            container.backgroundColor = UIColor(white: 0, alpha: 0.2)
            setUpAnimation(in: loadingView.layer, size: size, color: ColorCenter.shared.secondary.value)
        } else {
            setUpAnimation(in: loadingView.layer, size: size, color: ColorCenter.shared.secondary.value)
        }
        shared.inticators.append(container)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            container.isHidden = false
        }
    }
    
    class func dismiss() {
        shared.inticators.removeLast().removeFromSuperview()
    }
    
    class func dismissOnView(_ view: UIView) {
        guard let v = shared.inticators.first(where: { $0.superview == view }) else { return }
        v.removeFromSuperview()
        shared.inticators.removeFirst(v)
    }
    
    class func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let lineSize = size.width / 9
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0, 0.1, 0.2, 0.3, 0.4]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)

        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.y")

        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.4, 1]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        // Draw lines
        for i in 0 ..< 5 {
            let line: CAShapeLayer = CAShapeLayer()
            var path: UIBezierPath = UIBezierPath()
            let size = CGSize(width: lineSize, height: size.height)
            path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height),
                                cornerRadius: size.width / 2)
            line.fillColor = color.cgColor
            line.backgroundColor = nil
            line.path = path.cgPath
            line.frame = CGRect(x: x + lineSize * 2 * CGFloat(i), y: y, width: size.width, height: size.height)

            animation.beginTime = beginTime + beginTimes[i]
            line.add(animation, forKey: "animation")
            layer.addSublayer(line)
        }
    }
}
