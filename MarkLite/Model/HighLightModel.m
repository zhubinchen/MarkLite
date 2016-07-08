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
    UIFont *font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:15];
    if (_italic) {
        CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0);

        UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:[Configure sharedConfigure].fontName matrix :matrix];
        font = [UIFont fontWithDescriptor:desc size:15];
    }
    return @{
             NSFontAttributeName : font ? font : [UIFont systemFontOfSize:15],
             NSForegroundColorAttributeName : _textColor,
             NSBackgroundColorAttributeName : _backgroudColor,
             NSStrikethroughStyleAttributeName : @(_deletionLine ? NSUnderlineStyleSingle : NSUnderlineStyleNone)
             };
}

@end
