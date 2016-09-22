//
//  ImageUploadingView.h
//  MarkLite
//
//  Created by zhubch on 6/29/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageUploadingView : UIView

@property (nonatomic,copy) NSString *title;

@property (nonatomic,assign) CGFloat percent;

@property (nonatomic,copy) void(^cancelBlock)();

- (instancetype)initWithTitle:(NSString*)title cancelBlock:(void(^)())block;

- (void)show;

- (void)dismiss;

@end
