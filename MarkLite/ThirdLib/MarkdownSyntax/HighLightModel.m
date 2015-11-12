//
//  HighLightModel.m
//  MarkLite
//
//  Created by zhubch on 11/12/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "HighLightModel.h"

@implementation HighLightModel

- (instancetype)init
{
    if (self = [super init]) {
        _size = 15;
        _textColor = [UIColor blackColor];
        _backgroundColor = [UIColor clearColor];
        _deletionLine = NO;
        _underLine = NO;
        _strong = NO;
    }
    return self;
}

- (NSDictionary *)attribute
{
    UIFont *font = nil;
    if (_strong) {
        font = [UIFont boldSystemFontOfSize:_size];
    }else{
        font = [UIFont systemFontOfSize:_size];
    }
    return @{
             NSFontAttributeName : font,
             NSBackgroundColorAttributeName : _backgroundColor,
             NSForegroundColorAttributeName : _textColor,
             NSStrikethroughStyleAttributeName : @(_deletionLine ? NSUnderlineStyleSingle : NSUnderlineStyleNone),
             NSUnderlineStyleAttributeName : @(_underLine ? NSUnderlineStyleSingle : NSUnderlineStyleNone)
             };
}

@end
