//
//  SeparatorLine.h
//  MarkLite
//
//  Created by Bingcheng on 11/24/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeparatorLine : UIView

@property (nonatomic,strong) UIColor *lineColor;

- (instancetype)initWithStart:(CGPoint)start width:(CGFloat)width color:(UIColor *)color;

@end
