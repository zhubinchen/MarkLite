//
//  HighLightModel.m
//  MarkLite
//
//  Created by zhubch on 11/12/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "HighLightModel.h"
#import "Configure.h"

@implementation HighLightModel

- (instancetype)init
{
    if (self = [super init]) {
        _size = 15;
        _textColor = [UIColor blackColor];
        _backgroudColor = [UIColor clearColor];
        _deletionLine = NO;
        _strong = NO;
    }
    return self;
}

- (NSDictionary *)attribute
{
    return @{
             NSFontAttributeName : [UIFont fontWithName:[Configure sharedConfigure].fontName size:_size],
             NSForegroundColorAttributeName : _textColor,
             NSBackgroundColorAttributeName : _backgroudColor,
             NSStrikethroughStyleAttributeName : @(_deletionLine ? NSUnderlineStyleSingle : NSUnderlineStyleNone)
             };
}

@end
