//
//  MarkdownRender.m
//  Markdown
//
//  Created by 朱炳程 on 2019/9/6.
//  Copyright © 2019 zhubch. All rights reserved.
//

#import "MarkdownRender.h"
#import <limits.h>
#import "document.h"
#import "html.h"
#import "hoedown_html_patch.h"

#define kStylePath [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"Resources"]

NS_INLINE hoedown_renderer *MPCreateHTMLRenderer(int flags)
{
    hoedown_renderer *htmlRenderer = hoedown_html_renderer_new(flags, 6);
//    htmlRenderer->blockcode = hoedown_patch_render_blockcode;
    htmlRenderer->listitem = hoedown_patch_render_listitem;
    
//    hoedown_html_renderer_state_extra *extra =
//    hoedown_malloc(sizeof(hoedown_html_renderer_state_extra));
    //    extra->language_addition = language_addition;
//    extra->owner = (__bridge void *)renderer;
    
//    ((hoedown_html_renderer_state *)htmlRenderer->opaque)->opaque = extra;
    return htmlRenderer;
}

NS_INLINE hoedown_renderer *MPCreateHTMLTOCRenderer()
{
    hoedown_renderer *tocRenderer =
    hoedown_html_toc_renderer_new(6);
    tocRenderer->header = hoedown_patch_render_toc_header;
    return tocRenderer;
}

NS_INLINE void MPFreeHTMLRenderer(hoedown_renderer *htmlRenderer)
{
    hoedown_html_renderer_free(htmlRenderer);
}

NS_INLINE NSString *MPHTMLFromMarkdown(
                                       NSString *text, int flags, BOOL smartypants,
                                       hoedown_renderer *htmlRenderer, hoedown_renderer *tocRenderer)
{
    NSData *inputData = [text dataUsingEncoding:NSUTF8StringEncoding];
    hoedown_document *document = hoedown_document_new(htmlRenderer, flags, SIZE_MAX);
    hoedown_buffer *ob = hoedown_buffer_new(64);
    hoedown_document_render(document, ob, inputData.bytes, inputData.length);
    if (smartypants)
    {
        hoedown_buffer *ib = ob;
        ob = hoedown_buffer_new(64);
        hoedown_html_smartypants(ob, ib->data, ib->size);
        hoedown_buffer_free(ib);
    }
    NSString *result = [NSString stringWithUTF8String:hoedown_buffer_cstr(ob)];
    hoedown_document_free(document);
    hoedown_buffer_free(ob);
    
    if (tocRenderer)
    {
        document = hoedown_document_new(tocRenderer, flags, SIZE_MAX);
        ob = hoedown_buffer_new(64);
        hoedown_document_render(
                                document, ob, inputData.bytes, inputData.length);
        NSString *toc = [NSString stringWithUTF8String:hoedown_buffer_cstr(ob)];
        
        static NSRegularExpression *tocRegex = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *pattern = @"<p.*?>\\s*\\[TOC\\]\\s*</p>";
            NSRegularExpressionOptions ops = NSRegularExpressionCaseInsensitive;
            tocRegex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                            options:ops
                                                              error:NULL];
        });
        NSRange replaceRange = NSMakeRange(0, result.length);
        result = [tocRegex stringByReplacingMatchesInString:result options:0
                                                      range:replaceRange
                                               withTemplate:toc];
        hoedown_document_free(document);
        hoedown_buffer_free(ob);
    }
    
    return result;
}

@implementation MarkdownRender

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static MarkdownRender *render = nil;
    dispatch_once(&onceToken, ^{
        render = [[MarkdownRender alloc] init];
    });
    return render;
}

- (instancetype)init {
    if (self = [super init]) {
        self.styleName = @"GitHub";
        self.highlightName = @"tomorrow";
        self.title = @"Title";
    }
    return self;
}

- (NSString*)renderMarkdown:(NSString*)markdown {
    hoedown_renderer *htmlRenderer = MPCreateHTMLRenderer([self rendererFlags]);
    hoedown_renderer *tocRenderer = MPCreateHTMLTOCRenderer();
    int extensions = [self extensionFlags];
    NSString *html = MPHTMLFromMarkdown(markdown, extensions, YES, htmlRenderer, tocRenderer);
    hoedown_html_renderer_free(tocRenderer);
    MPFreeHTMLRenderer(htmlRenderer);
    
    NSString *stylePath = [NSString stringWithFormat:@"Styles/%@.css",self.styleName];
    NSString *highlightPath = [NSString stringWithFormat:@"Highlight/highlight-style/%@.css",self.highlightName];
    NSString *highlightJS1 = @"Highlight/highlightjs/highlight.min.js";
    NSString *highlightJS2 = @"Highlight/highlightjs/swift.min.js";
    NSString *MathJaxJS = @"MathJax/MathJax.js";
    return [self formatHTML:html title:(self.title?:@"") styles:@[stylePath,highlightPath] scripts:@[highlightJS1,highlightJS2,MathJaxJS]];
}

- (NSString*)formatHTML:(NSString*)body title:(NSString*)title styles:(NSArray<NSString*>*)styles scripts:(NSArray<NSString*>*)scripts {
    NSMutableString *styleSheets = @"".mutableCopy;
    NSMutableString *scriptsString = @"".mutableCopy;
    for (NSString *style in styles) {
        [styleSheets appendFormat:@"\n<link rel=\"stylesheet\" href=\"%@\"/>",[NSURL fileURLWithPath:[kStylePath stringByAppendingPathComponent:style]]];
    }
    for (NSString *script in scripts) {
        [scriptsString appendFormat:@"\n<script src=\"%@\"></script>",[NSURL fileURLWithPath:[kStylePath stringByAppendingPathComponent:script]]];
    }
    static NSString *template = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [kStylePath stringByAppendingPathComponent:@"Templates/default.html"];
        template = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    });
    return [NSString stringWithFormat:template,title,styleSheets,scriptsString,body];
}

- (int)extensionFlags
{
    int flags = 0;
    flags |= HOEDOWN_EXT_AUTOLINK;
    flags |= HOEDOWN_EXT_FENCED_CODE;
    flags |= HOEDOWN_EXT_FOOTNOTES;
    flags |= HOEDOWN_EXT_HIGHLIGHT;
    flags |= HOEDOWN_EXT_NO_INTRA_EMPHASIS;
    flags |= HOEDOWN_EXT_QUOTE;
    flags |= HOEDOWN_EXT_STRIKETHROUGH;
    flags |= HOEDOWN_EXT_SUPERSCRIPT;
    flags |= HOEDOWN_EXT_TABLES;
    flags |= HOEDOWN_EXT_UNDERLINE;
    flags |= HOEDOWN_EXT_MATH;
    flags |= HOEDOWN_EXT_MATH_EXPLICIT;
    return flags;
}

- (int)rendererFlags
{
    int flags = 0;
    flags |= HOEDOWN_HTML_USE_TASK_LIST;
    flags |= HOEDOWN_HTML_HARD_WRAP;
    return flags;
}

@end
