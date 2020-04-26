//
//  UIScrollView+Snapshot.swift
//  Fusion
//
//  Created by 朱炳程 on 2020/3/14.
//  Copyright © 2020 朱炳程. All rights reserved.
//

import WebKit

extension WKWebView {

    func takeSnapshot(delay:TimeInterval = 0.01,
                      progress:((Float)->(Void))?,
                      completion:((UIImage?)->(Void))?) {
        let snapShotView = snapshotView(afterScreenUpdates: true)
        if snapShotView != nil {
            snapShotView?.frame = self.frame
            superview?.addSubview(snapShotView!)
        }
        let page = floor(scrollView.contentSize.height/size.height)
        var scale = UIScreen.main.scale
        if self.h > windowHeight * 10 {
            scale = max((1 - (h / windowHeight) * 0.01) * scale,1)
        }
        let offset = scrollView.contentOffset
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.w, height: scrollView.contentSize.height), true, scale)
        scrollPageDraw(0, end: Int(page), delay: delay, progress: progress) { () -> (Void) in
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completion?(image)
            self.scrollView.contentOffset = offset
            snapShotView?.removeFromSuperview()
        }
    }
    
    func scrollPageDraw(_ index: Int,
                        end: Int,
                        delay:TimeInterval,
                        progress:((Float)->(Void))?,
                        completion:@escaping (()->(Void))) {
        scrollView.contentOffset = CGPoint(x: 0, y: size.height * CGFloat(index))
        let splitFrame = CGRect(x: 0, y: size.height * CGFloat(index), w: size.width, h: size.height)
        DispatchQueue.main.asyncAfter(deadline:.now() + delay) {
            self.scrollView.drawHierarchy(in: splitFrame, afterScreenUpdates: true)
            if index >= end {
                completion()
            } else {
                progress?(Float(index+1)/Float(end+1))
                self.scrollPageDraw(index + 1, end: end, delay: delay, progress: progress, completion: completion)
            }
        }
    }
}
