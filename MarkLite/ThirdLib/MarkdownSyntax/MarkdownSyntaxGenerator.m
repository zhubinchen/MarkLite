//
// Created by azu on 2013/10/26.
//


#import "MarkdownSyntaxGenerator.h"


#define regexp(reg,option) [NSRegularExpression regularExpressionWithPattern:@reg options:option error:NULL]

NSRegularExpression *NSRegularExpressionFromMarkdownSyntaxType(MarkdownSyntaxType v) {
    switch (v) {
        case MarkdownSyntaxUnknown:
            return nil;
        case MarkdownSyntaxHeaders://标题
            return regexp("(#+)(.*)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxLinks://链接（还有图片）
            return regexp("!?\\[([^\\[]+)\\]\\(([^\\)]+)\\)", 0);
        case MarkdownSyntaxBold://粗体
            return regexp("(\\*\\*|__)(.*?)\\1", 0);
        case MarkdownSyntaxEmphasis://强调
            return regexp("\\s(\\*|_)(.*?)\\1\\s", 0);
        case MarkdownSyntaxDeletions:
            return regexp("\\~\\~(.*?)\\~\\~", 0);
        case MarkdownSyntaxQuotes://引用
            return regexp("\\:\\\"(.*?)\\\"\\:", 0);
        case MarkdownSyntaxInlineCode:
            return regexp("`(.*?)`", 0);
        case MarkdownSyntaxCodeBlock:
            return regexp("```([\\s\\S]*?)```", 0);
        case MarkdownSyntaxImplicitCodeBlock:
            return regexp("```([\\s\\S]*?)```", 0);
//            return regexp("^ {4,}(.*)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxBlockquotes:
            return regexp("\n(&gt;|\\>)(.*)",0);
        case MarkdownSyntaxSeparate://分割线
            return regexp("-{3,}|\\*{3,}|_{3,}",0);
        case MarkdownSyntaxULLists://无序列表
            return regexp("^-{1,2}[\\s]+", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxOLLists://有序列表
            return regexp("^[0-9]+\\.(.*)", NSRegularExpressionAnchorsMatchLines);
        case MarkdownSyntaxLable://html标签
            return regexp("^<[a-z]+(\\s.*?)?>.+<\\/>$|^<[a-z]+(\\s.*?)?/>$", NSRegularExpressionAnchorsMatchLines);
        case NumberOfMarkdownSyntax:
            break;
    }
    return nil;
}

NSDictionary *AttributesFromMarkdownSyntaxType(MarkdownSyntaxType v) {
    switch (v) {
        case MarkdownSyntaxUnknown:
            return @{};
        case MarkdownSyntaxHeaders:
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                return @{
                    NSFontAttributeName : [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]
                };
            } else {
                return @{
                    NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                };
            }
        case MarkdownSyntaxLinks:
            return @{NSForegroundColorAttributeName : [UIColor blueColor]};
        case MarkdownSyntaxBold:
            return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]};
        case MarkdownSyntaxEmphasis:
            return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:16]};
        case MarkdownSyntaxDeletions:
            return @{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)};
        case MarkdownSyntaxQuotes:
            return @{NSForegroundColorAttributeName : [UIColor orangeColor]};
        case MarkdownSyntaxInlineCode:
            return @{NSForegroundColorAttributeName : [UIColor brownColor]};
        case MarkdownSyntaxCodeBlock:
            return @{NSBackgroundColorAttributeName : [UIColor colorWithWhite:0.96 alpha:1]};
        case MarkdownSyntaxImplicitCodeBlock:
            return @{NSBackgroundColorAttributeName : [UIColor colorWithWhite:0.5 alpha:1]};
        case MarkdownSyntaxBlockquotes:
            return @{NSForegroundColorAttributeName : [UIColor redColor]};
        case MarkdownSyntaxSeparate:
            return @{NSForegroundColorAttributeName : [UIColor purpleColor]};
        case MarkdownSyntaxULLists:
            return @{NSForegroundColorAttributeName : [UIColor greenColor]};
        case MarkdownSyntaxOLLists:
            return @{NSForegroundColorAttributeName : [UIColor greenColor]};
        case MarkdownSyntaxLable:
            return @{NSForegroundColorAttributeName : [UIColor blueColor]};
        case NumberOfMarkdownSyntax:
            break;
    }
    return nil;
}


@implementation MarkdownSyntaxGenerator

- (NSArray *)syntaxModelsForText:(NSString *) text {
    NSMutableArray *markdownSyntaxModels = [NSMutableArray array];
    for (MarkdownSyntaxType i = MarkdownSyntaxUnknown; i < NumberOfMarkdownSyntax; i++) {
        NSRegularExpression *expression = NSRegularExpressionFromMarkdownSyntaxType(i);
        NSArray *matches = [expression matchesInString:text
                                       options:0
                                       range:NSMakeRange(0, [text length])];
        for (NSTextCheckingResult *result in matches) {
            [markdownSyntaxModels addObject:[MarkdownSyntaxModel modelWithType:i range:result.range]];
        }
    }
    return markdownSyntaxModels;
}

@end