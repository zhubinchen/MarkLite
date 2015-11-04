//
//  ZBCSwipeButton.m
//  test
//
//  Created by Zhubch on 15-2-11.
//  Copyright (c) 2015年 Zhubch. All rights reserved.
//

#import "ZBCSwipeButton.h"

@implementation ZBCSwipeButton
{
    NSMutableArray *labels;
    CGPoint beginPoint;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {

        [self createLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = _pressedColor;
    for (int i = 0; i < 5; i++) {
        UILabel *label = (UILabel*)[self viewWithTag:i+1];
        label.textColor = _pressedTextColor;
    }
    UITouch *touch = touches.anyObject;
    beginPoint = [touch locationInView:self];
    self.tintIndex = 5;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = _color;
    for (UILabel *l in self.subviews) {
        l.textColor = _textColor;
    }
    [self.delegate choosedKey:[_keys substringWithRange:NSMakeRange(_tintIndex - 1, 1)]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = _color;
    for (UILabel *l in self.subviews) {
        l.textColor = _textColor;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self];
    CGPoint offset = CGPointMake(p.x - beginPoint.x, p.y - beginPoint.y);
    
    if (offset.x < 0 && offset.y<0) {
        self.tintIndex = 1;
    }
    else if(offset.x > 0 && offset.y<0){
        self.tintIndex = 2;
    }
    else if(offset.x < 0 && offset.y>0){
        self.tintIndex = 3;
    }
    else if(offset.x > 0 && offset.y>0){
        self.tintIndex = 4;
    }
}

- (void)setKeys:(NSString *)keys
{
    _keys = keys;
    for (int i = 0; i < 5; i++) {
        NSString *key = [keys substringWithRange:NSMakeRange(i, 1)];
        UILabel *label = (UILabel*)[self viewWithTag:i+1];
        label.text = key;
    }
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.backgroundColor = color;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    for (int i = 0; i < 5; i++) {
        UILabel *label = (UILabel*)[self viewWithTag:i+1];
        label.textColor = textColor;
    }
}

- (void)setTintIndex:(int)tintIndex
{
    _tintIndex = tintIndex;
    
    for (UILabel *l in self.subviews) {
        if (l.tag == tintIndex) {
            l.textColor = _tintTextcolor;
        }else {
            l.textColor = _pressedTextColor;
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    
    [labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *l = obj;
        switch (idx) {
            case 0:
                l.frame = CGRectMake(0, 0, 20, 20);
                break;
            case 1:
                l.frame = CGRectMake(w-20, 0, 20, 20);
                break;
            case 2:
                l.frame = CGRectMake(0, h-20, 20, 20);
                break;
            case 3:
                l.frame = CGRectMake(w-20, h-20, 20, 20);
                break;
            case 4:
                l.frame = CGRectMake(w*0.5-10, h*0.5-10, 20, 20);
                break;
                
            default:
                break;
        }
    }];
}

- (void)createLabel
{
    labels = [NSMutableArray array];
    for (int i = 0; i < 5; i ++) {
        UILabel *l = [[UILabel alloc]initWithFrame:CGRectZero];
        l.textAlignment = NSTextAlignmentCenter;
        l.font = [UIFont boldSystemFontOfSize:17];
        l.tag = i+1;
        [self addSubview:l];
        [labels addObject:l];
    }
}

@end
