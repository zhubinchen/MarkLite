//
//  WKWebView+ScreenShot.h
//  Markdown
//
//  Created by 朱炳程 on 2019/11/30.
//  Copyright © 2019 zhubch. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView(ScreenShot)

- (void)captureScreenShotWithCompletionHandler:(void(^)(UIImage *capturedImage))completionHandler;

@end
