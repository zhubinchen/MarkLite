//
//  MarkdownSyntaxGenerator.h
//  MarkLite
//
//  Created by Bingcheng on 11/12/15.
//  Copyright © 2016 Bingcheng. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HighLightModel.h"
#import "Configure.h"

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

#define regexp(reg,option) [NSRegularExpression regularExpressionWithPattern:@reg options:option error:NULL]

static NSDictionary* attributesFromMarkdownSyntaxType(MarkdownSyntaxType type) {
    static NSMutableArray *attrArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attrArray = [NSMutableArray array];
        for (MarkdownSyntaxType v = MarkdownSyntaxHeaders; v < NumberOfMarkdownSyntax; v++) {
            HighLightModel *model = [[HighLightModel alloc]init];
            NSDictionary *colors = [Configure sharedConfigure].highlightColor;
            switch (v) {
                case MarkdownSyntaxHeaders:
                    model.textColor = colors[@"title"];
                    model.size = 17;
                    break;
                case MarkdownSyntaxTitle:
                    model.textColor = colors[@"title"];
                    model.size = 17;
                    break;
                case MarkdownSyntaxLinks:
                    model.textColor = colors[@"link"];
                    break;
                case MarkdownSyntaxImages:
                    model.textColor = colors[@"image"];
                    break;
                case MarkdownSyntaxBold:
                    model.textColor = colors[@"bold"];
                    model.strong = YES;
                    break;
                case MarkdownSyntaxEmphasis:
                    model.textColor = colors[@"bold"];
                    model.italic = YES;
                    break;
                case MarkdownSyntaxDeletions:
                    model.textColor = colors[@"deletion"];
                    model.deletionLine = YES;
                    break;
                case MarkdownSyntaxQuotes:
                    model.textColor = colors[@"quotes"];
                    break;
                case MarkdownSyntaxInlineCode:
                    model.textColor = colors[@"code"];
                    break;
                case MarkdownSyntaxBlockquotes:
                    model.textColor = colors[@"quotes"];
                    break;
                case MarkdownSyntaxSeparate:
                    model.textColor = colors[@"separate"];
                    break;
                case MarkdownSyntaxULLists:
                    model.textColor = colors[@"list"];
                    break;
                case MarkdownSyntaxOLLists:
                    model.textColor = colors[@"list"];
                    break;
                case MarkdownSyntaxCodeBlock:
                    model.textColor = colors[@"code"];
                    break;
                case MarkdownSyntaxImplicitCodeBlock:
                    model.textColor = colors[@"code"];
                    break;
                case NumberOfMarkdownSyntax:
                    break;
            }
            [attrArray addObject:model.attribute];
        }
    });
    
    return attrArray[type];
}

static NSMutableAttributedString* init(NSString *text){
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]initWithString:text];
    CGFloat size = [Configure sharedConfigure].fontSize;
    UIFont *font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:size];
    if (font == nil) {
        font = [UIFont systemFontOfSize:size];
    }
    [attrString addAttributes:@{NSFontAttributeName:font} range:NSMakeRange(0, text.length)];
    
    return attrString;
}

static NSAttributedString* syntaxModelsForText(NSString *text) {
    static NSArray *regexpArray = nil;
    static NSUInteger count = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regexpArray = @[
                        regexp("^#{1,6} .*", NSRegularExpressionAnchorsMatchLines),//header
                        regexp(".*\\n=+[(\\s)|=]+", 0),//Title
                        regexp("(\\[.+\\]\\([^\\)]+\\))|(<.+>)", 0),//Links
                        regexp("!\\[[^\\]]+\\]\\([^\\)]+\\)", 0),//Images
                        regexp("(\\*\\*|__)(.*?)\\1", 0),//Bold
                        regexp("(\\*|_)(.*?)\\1", 0),//Emphasis
                        regexp("\\~\\~(.*?)\\~\\~", 0),//Deletions
                        regexp("\\:\\\"(.*?)\\\"\\:", 0),//Quotes
                        regexp("`{1,2}[^`](.*?)`{1,2}", 0),//InlineCode
                        regexp("\n(&gt;|\\>)(.*)",0),//Blockquotes://引用块
                        regexp("^-+$", NSRegularExpressionAnchorsMatchLines),//Separate://分割线
                        regexp("^[\\s]*[-\\*\\+] +(.*)", NSRegularExpressionAnchorsMatchLines),//ULLists://无序列表
                        regexp("^[\\s]*[0-9]+\\.(.*)", NSRegularExpressionAnchorsMatchLines),//OLLists有序列表
                        regexp("```([\\s\\S]*?)```[\\s]?", 0),//CodeBlock```包围的代码块
                        regexp("^\n[ \f\r\t\v]*(( {4}|\\t).*(\\n|\\z))+", NSRegularExpressionAnchorsMatchLines),//ImplicitCodeBlock4个缩进也算代码块
                        ];
        count = regexpArray.count;
    });
    
    NSMutableAttributedString *attrString = init(text);
    
    for (MarkdownSyntaxType type = MarkdownSyntaxHeaders; type < NumberOfMarkdownSyntax; type++) {
        NSRegularExpression *expression = regexpArray[type];
        NSArray *matches = [expression matchesInString:text
                                               options:0
                                                 range:NSMakeRange(0, [text length])];
        
        for (NSTextCheckingResult *result in matches) {
            NSDictionary *attribute = attributesFromMarkdownSyntaxType(type);
            [attrString addAttributes:attribute range:result.range];
        }
    }
    
    return attrString;
}


