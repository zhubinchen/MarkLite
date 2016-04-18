//
//  PreviewViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-28.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "PreviewViewController.h"
#import "FileManager.h"
#import "HoedownHelper.h"
#import "Item.h"
#import "Configure.h"

@interface PreviewViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PreviewViewController
{
    FileManager *fm;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.scalesPageToFit = YES;

    fm = [FileManager sharedManager];
   
    if (kDevicePhone) {
        [self loadFile];
    } else {
        [fm addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    _webView.delegate = self;
    
    if (fm.currentItem) {
        [self loadFile];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self loadFile];
}

- (void)loadFile
{
    NSString *path = [fm fullPathForPath:[fm currentItem].path];
    NSArray *arr = [path componentsSeparatedByString:@"."];
    NSString *ex = arr.lastObject;
    if ([ex isEqualToString:@"png"] || [ex isEqualToString:@"jpeg"] || [ex isEqualToString:@"jpg"] || [ex isEqualToString:@"gif"]) {
        NSURL *url = [NSURL fileURLWithPath:path];
        NSString *imageHtmlFile = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"html"];
        NSString *html = [NSString stringWithContentsOfFile:imageHtmlFile encoding:NSUTF8StringEncoding error:nil];
        html = [NSString stringWithFormat:html,url.absoluteString];
        [_webView loadHTMLString:html baseURL:nil];
    }else{
        hoedown_renderer *render = CreateHTMLRenderer();
        NSString *markdown = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *html = HTMLFromMarkdown(markdown, HOEDOWN_EXT_BLOCK|HOEDOWN_EXT_SPAN|HOEDOWN_EXT_FLAGS, YES, @"", render, CreateHTMLTOCRenderer());
        NSString *formatHtmlFile = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
        NSString *format = [NSString stringWithContentsOfFile:formatHtmlFile encoding:NSUTF8StringEncoding error:nil];
        
        
        NSString *styleFile = [[NSBundle mainBundle] pathForResource:[Configure sharedConfigure].style ofType:@"css"];
        NSString *style = [NSString stringWithContentsOfFile:styleFile encoding:NSUTF8StringEncoding error:nil];
        NSString *finalHtml = [[format stringByReplacingOccurrencesOfString:@"#_html_place_holder_#" withString:html] stringByReplacingOccurrencesOfString:@"#_style_place_holder_#" withString:style];
        NSLog(@"%@",finalHtml);
        [_webView loadHTMLString:finalHtml baseURL:[NSURL fileURLWithPath:path]];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"zzz");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"xxx");
}

- (void)dealloc
{
    if (kDevicePad) {
        [fm removeObserver:self forKeyPath:@"currentItem" context:NULL];
    }
}

@end
