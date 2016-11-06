//
//  MarkdownSyntaxModel.m
//  MarkLite
//
//  Created by zhubch on 11/12/15.
//  Copyright © 2016 zhubch. All rights reserved.
//


#import "MarkdownSyntaxModel.h"

@implementation MarkdownSyntaxModel

- (instancetype)initWithType:(enum MarkdownSyntaxType) type range:(NSRange) range {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.type = type;
    self.range = range;

    return self;
}

+ (instancetype)modelWithType:(enum MarkdownSyntaxType) type range:(NSRange) range {
    return [[self alloc] initWithType:type range:range];
}

@end
