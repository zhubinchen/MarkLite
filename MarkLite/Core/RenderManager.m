//
//  RenderManager.m
//  MarkLite
//
//  Created by zhubch on 2017/7/3.
//  Copyright © 2017年 zhubch. All rights reserved.
//

#import "RenderManager.h"
#import "hoedown_helper.h"

#define HTML @"<html lang=\"zh-CN\"><head><meta charset=\"UTF-8\"><style type=\"text/css\"></style><link rel=\"stylesheet\" href=\"%@\"></style><link rel=\"stylesheet\" href=\"%@\"><script src=\"%@\"></script><script src=\"%@\"></script><script>hljs.initHighlightingOnLoad();</script></head><body>%@</body></html>"

@implementation RenderManager
{
    hoedown_renderer *htmlRender;
    hoedown_renderer *tocRender;
}

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static RenderManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        htmlRender = CreateHTMLRenderer();
        tocRender = CreateHTMLTOCRenderer();
    }
    return self;
}

- (NSString*)render:(NSString *)string {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *styleDir = [docPath stringByAppendingPathComponent:@"markdown-style"];
    NSString *styleFile = [NSURL fileURLWithPath:[[styleDir stringByAppendingPathComponent:self.markdownStyle] stringByAppendingPathExtension:@"css"]].absoluteString;
    
    NSString *highlightStyleDir = [docPath stringByAppendingPathComponent:@"highlight-style"];
    NSString *highlightStyleFile = [NSURL fileURLWithPath:[[highlightStyleDir stringByAppendingPathComponent:self.highlightStyle] stringByAppendingPathExtension:@"css"]].absoluteString;
    
    NSString *highlightjs1 = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:@"highlightjs/highlight.min.js"]].absoluteString;
    NSString *highlightjs2 = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:@"highlightjs/swift.min.js"]].absoluteString;
    NSString *body = HTMLFromMarkdown(string, HOEDOWN_EXT_BLOCK|HOEDOWN_EXT_SPAN|HOEDOWN_EXT_FLAGS, YES, @"", htmlRender, tocRender);
    return [NSString stringWithFormat:HTML,styleFile,highlightStyleFile,highlightjs1,highlightjs2,body];
}

@end
