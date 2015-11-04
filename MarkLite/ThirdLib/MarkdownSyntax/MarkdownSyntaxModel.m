//
// Created by azu on 2013/10/26.
//


#import "MarkdownSyntaxModel.h"




@implementation MarkdownSyntaxModel {

}
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