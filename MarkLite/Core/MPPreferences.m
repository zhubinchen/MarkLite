//
//  MPPreferences.m
//  Markdown
//
//  Created by 朱炳程 on 2019/9/5.
//  Copyright © 2019 zhubch. All rights reserved.
//

#import "MPPreferences.h"
#import "document.h"
#import "hoedown_html_patch.h"
#import "html.h"
#import "MPRenderer.h"
#import <UIKit/UIKit.h>

@implementation MPPreferences

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MPPreferences *pref = nil;
    dispatch_once(&onceToken, ^{
        pref = [[self alloc] init];
        [pref reset];
    });
    return pref;
}

- (void)reset {
    self.extensionIntraEmphasis = YES;
    self.extensionTables = YES;
    self.extensionFencedCode = YES;
    self.extensionFootnotes = YES;
    self.extensionSmartyPants = YES;
    self.extensionStrikethough = YES;
    self.extensionQuote = YES;
    self.extensionAutolink = YES;
    self.extensionHighlight = YES;
    self.extensionUnderline = YES;
    self.extensionSuperscript = YES;
    
    self.htmlDetectFrontMatter = YES;
    self.htmlTaskList = YES;
    self.htmlMermaid = YES;
    self.htmlMathJax = YES;
    self.htmlMathJaxInlineDollar = YES;
    self.htmlSyntaxHighlighting = YES;
    self.htmlLineNumbers = YES;
    self.htmlGraphviz = YES;
    self.htmlRendersTOC = YES;
    self.htmlCodeBlockAccessory = MPCodeBlockAccessoryLanguageName;
}

- (int)extensionFlags
{
    int flags = 0;
    if (self.extensionAutolink)
        flags |= HOEDOWN_EXT_AUTOLINK;
    if (self.extensionFencedCode)
        flags |= HOEDOWN_EXT_FENCED_CODE;
    if (self.extensionFootnotes)
        flags |= HOEDOWN_EXT_FOOTNOTES;
    if (self.extensionHighlight)
        flags |= HOEDOWN_EXT_HIGHLIGHT;
    if (!self.extensionIntraEmphasis)
        flags |= HOEDOWN_EXT_NO_INTRA_EMPHASIS;
    if (self.extensionQuote)
        flags |= HOEDOWN_EXT_QUOTE;
    if (self.extensionStrikethough)
        flags |= HOEDOWN_EXT_STRIKETHROUGH;
    if (self.extensionSuperscript)
        flags |= HOEDOWN_EXT_SUPERSCRIPT;
    if (self.extensionTables)
        flags |= HOEDOWN_EXT_TABLES;
    if (self.extensionUnderline)
        flags |= HOEDOWN_EXT_UNDERLINE;
    if (self.htmlMathJax)
        flags |= HOEDOWN_EXT_MATH;
    if (self.htmlMathJaxInlineDollar)
        flags |= HOEDOWN_EXT_MATH_EXPLICIT;
    return flags;
}

- (int)rendererFlags
{
    int flags = 0;
    if (self.htmlTaskList)
        flags |= HOEDOWN_HTML_USE_TASK_LIST;
    if (self.htmlLineNumbers)
        flags |= HOEDOWN_HTML_BLOCKCODE_LINE_NUMBERS;
    if (self.htmlHardWrap)
        flags |= HOEDOWN_HTML_HARD_WRAP;
    if (self.htmlCodeBlockAccessory == MPCodeBlockAccessoryCustom)
        flags |= HOEDOWN_HTML_BLOCKCODE_INFORMATION;
    return flags;
}

@end
