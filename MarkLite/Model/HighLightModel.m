//
//  HighLightModel.m
//  MarkLite
//
//  Created by zhubch on 11/12/15.
//  Copyright © 2016 zhubch. All rights reserved.
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
    CGFloat size = [Configure sharedConfigure].fontSize;
    UIFont *font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:size];
    if (_italic) {
        CGAffineTransform matrix =  CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0);

        UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:[Configure sharedConfigure].fontName matrix :matrix];
        font = [UIFont fontWithDescriptor:desc size:size];
    }
    if (_strong) {
        UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:[Configure sharedConfigure].fontName size:size];
        desc = [desc fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        font = [UIFont fontWithDescriptor:desc size:size];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:size];
    }
    return @{
             NSFontAttributeName : font,
             NSForegroundColorAttributeName : _textColor,
             NSBackgroundColorAttributeName : _backgroudColor,
             NSStrikethroughStyleAttributeName : @(_deletionLine ? NSUnderlineStyleSingle : NSUnderlineStyleNone)
             };
}

@end
