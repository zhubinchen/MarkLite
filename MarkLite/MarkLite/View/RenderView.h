//
//  RenderView.h
//  MarkLite
//
//  Created by Bingcheng on 2016/11/27.
//  Copyright © 2016年 Bingcheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RenderView : UIWebView

@property (nonatomic,strong) NSString *text;
@property (nonatomic,readonly) NSString *html;
@end
