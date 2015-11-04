//
//  TokensManager.m
//  MarkLite
//
//  Created by zhubch on 15-3-30.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "TokensManager.h"
#import "CYRToken.h"
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

@implementation TokensManager

+ (instancetype)sharedManager
{
    static TokensManager *manager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
    
        manager = [[TokensManager alloc]init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSArray *solverTokens =  @[
                                   [CYRToken tokenWithName:@"div"
                                                expression:@"((<).*(>))"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(255, 0, 30)
                                                             }],
                                   [CYRToken tokenWithName:@"content"
                                                expression:@"((>).*(<))"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(100, 0, 200)
                                                             }],
                                   [CYRToken tokenWithName:@"special_numbers"
                                                expression:@"[ʝ]"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"mod"
                                                expression:@"\bmod\b"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(245, 0, 110)
                                                             }],
                                   [CYRToken tokenWithName:@"hex_1"
                                                expression:@"\\$[\\d a-f]+"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"octal_1"
                                                expression:@"&[0-7]+"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"binary_1"
                                                expression:@"%[01]+"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"hex_2"
                                                expression:@"0x[0-9 a-f]+"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"octal_2"
                                                expression:@"0o[0-7]+"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"binary_2"
                                                expression:@"0b[01]+"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"float"
                                                expression:@"\\d+\\.?\\d+e[\\+\\-]?\\d+|\\d+\\.\\d+|∞"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"integer"
                                                expression:@"\\d+"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(0, 0, 255)
                                                             }],
                                   [CYRToken tokenWithName:@"operator"
                                                expression:@"[/\\*,\\;:=<>\\+\\-\\^!·≤≥]"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(245, 0, 110)
                                                             }],
                                   [CYRToken tokenWithName:@"round_brackets"
                                                expression:@"[\\(\\)]"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(161, 75, 0)
                                                             }],
                                   [CYRToken tokenWithName:@"square_brackets"
                                                expression:@"[\\[\\]]"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(105, 0, 0),
                                                             NSFontAttributeName : [UIFont systemFontOfSize:14]
                                                             }],
                                   [CYRToken tokenWithName:@"absolute_brackets"
                                                expression:@"[|]"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(104, 0, 111)
                                                             }],
                                   [CYRToken tokenWithName:@"reserved_words"
                                                expression:@"(html|title|body|a|href|class|link|head|h1|h2|h3|h4|h5|h6|h7|h8|h9|h10|section|id|rel|meta|charset|imag|inf|integ|integhq|inv|ln|log10|log2|machineprecision|max|maximize|min|minimize|molecularweight|ncum|ones|pi|plot|random|real|round|sgn|sin|sqr|sinh|sqrt|tan|tanh|transpose|trunc|var|zeros)"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(104, 0, 111),
                                                             NSFontAttributeName : [UIFont systemFontOfSize:14]
                                                             }],
                                   [CYRToken tokenWithName:@"chart_parameters"
                                                expression:@"(chartheight|charttitle|chartwidth|color|seriesname|showlegend|showxmajorgrid|showxminorgrid|showymajorgrid|showyminorgrid|transparency|thickness|xautoscale|xaxisrange|xlabel|xlogscale|xrange|yautoscale|yaxisrange|ylabel|ylogscale|yrange)"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(11, 81, 195),
                                                             }],
                                   [CYRToken tokenWithName:@"string"
                                                expression:@"\".*?(\"|$)"
                                                attributes:@{
                                                             NSForegroundColorAttributeName : RGB(24, 110, 109)
                                                             }]
                                   ];
        
        
        self.tokens = solverTokens.mutableCopy;
    }
    
    return self;
}

@end
