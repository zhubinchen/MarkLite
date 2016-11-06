//
//  MarkdownSyntaxModel.h
//  MarkLite
//
//  Created by zhubch on 11/12/15.
//  Copyright © 2016 zhubch. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MarkdownSyntaxType){
    MarkdownSyntaxHeaders,
    MarkdownSyntaxTitle,
    MarkdownSyntaxLinks,
    MarkdownSyntaxImages,
    MarkdownSyntaxBold,
    MarkdownSyntaxEmphasis,
    MarkdownSyntaxDeletions,
    MarkdownSyntaxQuotes,
    MarkdownSyntaxBlockquotes,
    MarkdownSyntaxSeparate,
    MarkdownSyntaxULLists,
    MarkdownSyntaxOLLists,
    MarkdownSyntaxInlineCode,
    MarkdownSyntaxCodeBlock,
    MarkdownSyntaxImplicitCodeBlock,
    NumberOfMarkdownSyntax,
};

@interface MarkdownSyntaxModel : NSObject
@property(nonatomic) NSRange range;
@property(nonatomic) MarkdownSyntaxType type;

- (instancetype)initWithType:(enum MarkdownSyntaxType) type range:(NSRange) range;

+ (instancetype)modelWithType:(enum MarkdownSyntaxType) type range:(NSRange) range;

@end
