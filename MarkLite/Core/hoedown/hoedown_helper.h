//
//  hoedown_helper.h
//  MarkLite
//
//  Created by Bingcheng on 11/18/15.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#ifndef hoedown_helper_h
#define hoedown_helper_h

#import <limits.h>
#import "html.h"
#import "document.h"
#import "hoedown_html_patch.h"

static size_t kRendererNestingLevel = SIZE_MAX;
static int kRendererTOCLevel = 6;  // h1 to h6.

NS_INLINE NSString *HTMLFromMarkdown(
                                       NSString *text, hoedown_extensions flags, BOOL smartypants, NSString *frontMatter,
                                       hoedown_renderer *htmlRenderer, hoedown_renderer *tocRenderer)
{
    NSData *inputData = [text dataUsingEncoding:NSUTF8StringEncoding];
    hoedown_document *document = hoedown_document_new(
                                                      htmlRenderer, flags, kRendererNestingLevel);
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
        document = hoedown_document_new(
                                        tocRenderer, flags, kRendererNestingLevel);
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
        result = [tocRegex stringByReplacingMatchesInString:result options:0 range:replaceRange withTemplate:toc];
        hoedown_document_free(document);
        hoedown_buffer_free(ob);
    }
    if (frontMatter)
        result = [NSString stringWithFormat:@"%@\n%@", frontMatter, result];
    
    return result;
}

NS_INLINE BOOL AreNilableStringsEqual(NSString *s1, NSString *s2)
{
    // The == part takes care of cases where s1 and s2 are both nil.
    return ([s1 isEqualToString:s2] || s1 == s2);
}

NS_INLINE hoedown_renderer *CreateHTMLRenderer()
{
    int flags = 0;
    hoedown_renderer *htmlRenderer = hoedown_html_renderer_new(
                                                               flags, kRendererTOCLevel);
    htmlRenderer->blockcode = hoedown_patch_render_blockcode;
    htmlRenderer->listitem = hoedown_patch_render_listitem;
    
    hoedown_html_renderer_state_extra *extra =
    hoedown_malloc(sizeof(hoedown_html_renderer_state_extra));
    
    ((hoedown_html_renderer_state *)htmlRenderer->opaque)->opaque = extra;
    return htmlRenderer;
}

NS_INLINE hoedown_renderer *CreateHTMLTOCRenderer()
{
    hoedown_renderer *tocRenderer =
    hoedown_html_toc_renderer_new(kRendererTOCLevel);
    tocRenderer->header = hoedown_patch_render_toc_header;
    return tocRenderer;
}

NS_INLINE void FreeHTMLRenderer(hoedown_renderer *htmlRenderer)
{
    hoedown_html_renderer_state_extra *extra =
    ((hoedown_html_renderer_state *)htmlRenderer->opaque)->opaque;
    if (extra)
        free(extra);
    hoedown_html_renderer_free(htmlRenderer);
}

#endif /* HoedownHelper_h */
