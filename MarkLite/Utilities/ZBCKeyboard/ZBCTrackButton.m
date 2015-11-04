//
//  ZBCTrackButton.m
//  test
//
//  Created by Zhubch on 15-2-11.
//  Copyright (c) 2015年 Zhubch. All rights reserved.
//

#import "ZBCTrackButton.h"

@implementation ZBCTrackButton
{
    CGPoint beginPoint;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    beginPoint = [touches.anyObject locationInView:self];
    self.backgroundColor = _pressedColor;
    [self.delegate trackStarted]; 
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchMovePoint = [touches.anyObject locationInView:self];
    
    CGFloat xOffset = beginPoint.x - touchMovePoint.x;
    CGFloat yOffset = beginPoint.y - touchMovePoint.y;
    
    [self.delegate trackedWithX:xOffset AndY:yOffset];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = _color;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = _color;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.backgroundColor = _color;
}

@end
