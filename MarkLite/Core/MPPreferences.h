//
//  MPPreferences.h
//  Markdown
//
//  Created by 朱炳程 on 2019/9/5.
//  Copyright © 2019 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPPreferences : NSObject

@property (assign) BOOL htmlDetectFrontMatter;
@property (assign) BOOL htmlTaskList;
@property (assign) BOOL htmlHardWrap;
@property (assign) BOOL htmlMathJax;
@property (assign) BOOL htmlMathJaxInlineDollar;
@property (assign) BOOL htmlSyntaxHighlighting;
@property (assign) BOOL htmlLineNumbers;
@property (assign) BOOL htmlGraphviz;
@property (assign) BOOL htmlMermaid;
@property (assign) NSInteger htmlCodeBlockAccessory;
@property (assign) BOOL htmlRendersTOC;

@property (assign) BOOL extensionIntraEmphasis;
@property (assign) BOOL extensionTables;
@property (assign) BOOL extensionFencedCode;
@property (assign) BOOL extensionAutolink;
@property (assign) BOOL extensionStrikethough;
@property (assign) BOOL extensionUnderline;
@property (assign) BOOL extensionSuperscript;
@property (assign) BOOL extensionHighlight;
@property (assign) BOOL extensionFootnotes;
@property (assign) BOOL extensionQuote;
@property (assign) BOOL extensionSmartyPants;

@property (readonly) int extensionFlags;
@property (readonly) int rendererFlags;


+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
