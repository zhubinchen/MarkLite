//
//  JKSHoedownRenderer.h
//  CocoaHoedown
//
//  Created by Sørensen, Johan on 05.01.14.
//  Copyright (c) 2014 Frosthaus AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "markdown.h"
#import "html.h"

typedef NS_ENUM(NSUInteger, JKSMarkdownExtention) {
	JKSMarkdownExtentionNoIntraEmphasis = HOEDOWN_EXT_NO_INTRA_EMPHASIS,
	JKSMarkdownExtentionTables = HOEDOWN_EXT_TABLES,
	JKSMarkdownExtentionFencedCode = HOEDOWN_EXT_FENCED_CODE,
	JKSMarkdownExtentionAutolink = HOEDOWN_EXT_AUTOLINK,
	JKSMarkdownExtentionStrikethrough = HOEDOWN_EXT_STRIKETHROUGH,
	JKSMarkdownExtentionUnderline = HOEDOWN_EXT_UNDERLINE,
	JKSMarkdownExtentionSpaceHeaders = HOEDOWN_EXT_SPACE_HEADERS,
	JKSMarkdownExtentionSuperscript = HOEDOWN_EXT_SUPERSCRIPT,
	JKSMarkdownExtentionLaxSpacing = HOEDOWN_EXT_LAX_SPACING,
	JKSMarkdownExtentionDisableIndentedCode = HOEDOWN_EXT_DISABLE_INDENTED_CODE,
	JKSMarkdownExtentionHighlight = HOEDOWN_EXT_HIGHLIGHT,
	JKSMarkdownExtentionFootnotes = HOEDOWN_EXT_FOOTNOTES,
	JKSMarkdownExtentionQuote = HOEDOWN_EXT_QUOTE,
};

typedef NS_ENUM(NSUInteger, JKSMarkdownRenderOption) {
    JKSMarkdownRenderOptionSkipHTML = HOEDOWN_HTML_SKIP_HTML,
    JKSMarkdownRenderOptionSkipStyle = HOEDOWN_HTML_SKIP_STYLE,
    JKSMarkdownRenderOptionSkipImages = HOEDOWN_HTML_SKIP_IMAGES,
    JKSMarkdownRenderOptionSkipLinks = HOEDOWN_HTML_SKIP_LINKS,
    JKSMarkdownRenderOptionExpandTabs = HOEDOWN_HTML_EXPAND_TABS,
    JKSMarkdownRenderOptionSafeLink = HOEDOWN_HTML_SAFELINK,
    JKSMarkdownRenderOptionTableOfContents = HOEDOWN_HTML_TOC,
    JKSMarkdownRenderOptionHardWrap = HOEDOWN_HTML_HARD_WRAP,
    JKSMarkdownRenderOptionUseXHTML = HOEDOWN_HTML_USE_XHTML,
    JKSMarkdownRenderOptionEscape = HOEDOWN_HTML_ESCAPE,
    JKSMarkdownRenderOptionPrettify = HOEDOWN_HTML_PRETTIFY,
};

@interface JKSMarkdownDocument : NSObject
/// Whether or not to preprocess with "smarty pants". Defaults to NO
@property (nonatomic, assign, getter = isSmartyPantsEnabled) BOOL smartyPantsEnabled;
/// Mask of Markdown extentions to enable
@property (nonatomic, assign) JKSMarkdownExtention markdownExtentions;
/// Mask of HMTL render options to use
@property (nonatomic, assign) JKSMarkdownRenderOption renderOptions;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithString:(NSString *)string;

- (NSString *)HTML;
- (NSString *)tableOfContentsHTML;

@end
