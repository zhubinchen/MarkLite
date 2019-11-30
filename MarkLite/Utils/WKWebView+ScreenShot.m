//
//  WKWebView+ScreenShot.m
//  Markdown
//
//  Created by 朱炳程 on 2019/11/30.
//  Copyright © 2019 zhubch. All rights reserved.
//

#import "WKWebView+ScreenShot.h"

@implementation WKWebView(ScreenShot)

- (void)captureScreenShotWithCompletionHandler:(void(^)(UIImage *capturedImage))completionHandler{
    // 制作了一个UIView的副本
    UIView *snapShotView = [self snapshotViewAfterScreenUpdates:YES];

    snapShotView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, snapShotView.frame.size.width, snapShotView.frame.size.height);

    [self.superview addSubview:snapShotView];

    // 获取当前UIView可滚动的内容长度
    CGPoint scrollOffset = self.scrollView.contentOffset;

    // 向上取整数 － 可滚动长度与UIView本身屏幕边界坐标相差倍数
    float maxIndex = ceilf(self.scrollView.contentSize.height/self.bounds.size.height);

    // 保持清晰度
    UIGraphicsBeginImageContextWithOptions(self.scrollView.contentSize, false, [UIScreen mainScreen].scale);

    // 滚动截图
    [self contentScrollPageDraw:0 maxIndex:(int)maxIndex drawCallback:^{
        UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // 恢复原UIView
        [self.scrollView setContentOffset:scrollOffset animated:NO];
        [snapShotView removeFromSuperview];

        completionHandler(capturedImage);
    }];
}

// 滚动截图
- (void)contentScrollPageDraw:(int)index maxIndex:(int)maxIndex drawCallback:(void(^)(void))drawCallback{
    [self.scrollView setContentOffset:CGPointMake(0, (float)index * self.frame.size.height)];
    CGRect splitFrame = CGRectMake(0, (float)index * self.frame.size.height, self.bounds.size.width, self.bounds.size.height);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self drawViewHierarchyInRect:splitFrame afterScreenUpdates:YES];
        if(index < maxIndex){
            [self contentScrollPageDraw: index + 1 maxIndex:maxIndex drawCallback:drawCallback];
        }else{
            drawCallback();
        }
    });
}

@end
