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
        _deletionLine = NO;
        _strong = NO;
    }
    return self;
}

- (NSDictionary *)attribute
{
    UIFont *font = nil;

//    if (_strong) {
//        font = [UIFont boldSystemFontOfSize:_size];
//    }else{
//        font = [UIFont fontWithName:@"Hiragino Sans" size:_size];
//    }
    return @{
             NSFontAttributeName : [UIFont fontWithName:@"Hiragino Sans" size:_size],
             NSForegroundColorAttributeName : _textColor,
             NSStrikethroughStyleAttributeName : @(_deletionLine ? NSUnderlineStyleSingle : NSUnderlineStyleNone)
             };
}

@end
