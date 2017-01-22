//
//  RenderView.m
//  MarkLite
//
//  Created by Bingcheng on 2016/11/27.
//  Copyright © 2016年 Bingcheng. All rights reserved.
//

#import "RenderView.h"
#import "HoedownHelper.h"
#import "Configure.h"
#import "ZHUtils.h"

#define HTML @"<html lang=\"zh-CN\"><head><meta charset=\"UTF-8\"><style type=\"text/css\"></style><link rel=\"stylesheet\" href=\"%@\"></style><link rel=\"stylesheet\" href=\"%@\"><script src=\"%@\"></script><script src=\"%@\"></script><script>hljs.initHighlightingOnLoad();</script></head><body>%@</body></html>"

@interface RenderView ()<UIWebViewDelegate>

@end

@implementation RenderView
{
    
}

- (void)awakeFromNib
{
    self.scalesPageToFit = NO;
    self.delegate = self;
    [[Configure sharedConfigure] addObserver:self forKeyPath:@"style" options:NSKeyValueObservingOptionNew context:NULL];
    [super awakeFromNib];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    self.text = self.text;
}

- (void)setText:(NSString *)text
{
    _text = text;
    beginLoadingAnimationOnParent(self);
    
    dispatch_async(dispatch_queue_create("preview_queue", DISPATCH_QUEUE_CONCURRENT), ^{
        hoedown_renderer *render = CreateHTMLRenderer();
        NSString *body = HTMLFromMarkdown(text, HOEDOWN_EXT_BLOCK|HOEDOWN_EXT_SPAN|HOEDOWN_EXT_FLAGS, YES, @"", render, CreateHTMLTOCRenderer());
        
        NSString *styleDir = [documentPath() stringByAppendingPathComponent:@"StyleResource/markdown-style"];
        NSString *styleFile = [NSURL fileURLWithPath:[[styleDir stringByAppendingPathComponent:[Configure sharedConfigure].style]stringByAppendingPathExtension:@"css"]].absoluteString;
        
        NSString *highlightStyleDir = [documentPath() stringByAppendingPathComponent:@"StyleResource/highlight-style"];
        NSString *highlightStyleFile = [NSURL fileURLWithPath:[[highlightStyleDir stringByAppendingPathComponent:[Configure sharedConfigure].highlightStyle]stringByAppendingPathExtension:@"css"]].absoluteString;
        
        NSString *highlightjs1 = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:@"StyleResource/highlightjs/highlight.min.js"]].absoluteString;
        NSString *highlightjs2 = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:@"StyleResource/highlightjs/swift.min.js"]].absoluteString;
        
        _html = [NSString stringWithFormat:HTML,styleFile,highlightStyleFile,highlightjs1,highlightjs2,body];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",_html);
            [self loadHTMLString:_html baseURL:nil];
        });
    });
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    stopLoadingAnimationOnParent(self);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    stopLoadingAnimationOnParent(self);
}

- (void)dealloc
{
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
    [[Configure sharedConfigure] removeObserver:self forKeyPath:@"style"];
}

@end
