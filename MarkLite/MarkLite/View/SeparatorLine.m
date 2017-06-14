//
//  SeparatorLine.m
//  MarkLite
//
//  Created by Bingcheng on 11/24/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "SeparatorLine.h"

@implementation SeparatorLine

- (instancetype)initWithStart:(CGPoint)start width:(CGFloat)width color:(UIColor *)color
{
    if (self = [super initWithFrame:CGRectMake(start.x, start.y, width, 0.5)]) {
        self.lineColor = color;
        self.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置虚线颜色
    CGContextSetStrokeColorWithColor(currentContext, kPrimaryColor.CGColor);
    //设置虚线宽度
    CGContextSetLineWidth(currentContext, 0.5);
    //设置虚线绘制起点
    CGContextMoveToPoint(currentContext, 0, 0);
    //设置虚线绘制终点
    CGContextAddLineToPoint(currentContext, self.frame.origin.x + self.frame.size.width, 0);
    //设置虚线排列的宽度间隔:下面的arr中的数字表示先绘制3个点再绘制1个点
    CGFloat arr[] = {4,2};
    //下面最后一个参数“2”代表排列的个数。
    CGContextSetLineDash(currentContext, 0, arr, 2);
    CGContextDrawPath(currentContext, kCGPathStroke);
}


@end
