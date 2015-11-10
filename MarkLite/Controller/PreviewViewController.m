//
//  PreviewViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-28.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "PreviewViewController.h"
#import "FileManager.h"
#import <CocoaMarkdown/CocoaMarkdown.h>

@interface PreviewViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!kIsPhone) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, _size.width, _size.height)];
        _webView.scalesPageToFit = NO;
        [self setupNav];
        [self.view addSubview:_webView];
    }
    _webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *path = [FileManager sharedManager].currentFilePath;
    NSArray *arr = [path componentsSeparatedByString:@"."];
    NSString *ex = arr.lastObject;
    if ([ex isEqualToString:@"png"] || [ex isEqualToString:@"jpeg"] || [ex isEqualToString:@"jpg"] || [ex isEqualToString:@"gif"]) {
        NSURL *url = [NSURL fileURLWithPath:path];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }else{
        CMDocument *doc = [[CMDocument alloc]initWithContentsOfFile:path options:CMDocumentOptionsSmart];
        CMHTMLRenderer *render = [[CMHTMLRenderer alloc]initWithDocument:doc];
//        NSString *markDown = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *formatHtmlFile = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
        NSString *format = [NSString stringWithContentsOfFile:formatHtmlFile encoding:NSUTF8StringEncoding error:nil];
//        GHMarkdownParser *parser = [[GHMarkdownParser alloc] init];
//        parser.options = kGHMarkdownAutoLink; // for example
//        parser.githubFlavored = YES;
//        NSString *html = [parser HTMLStringFromMarkdownString:markDown];
        NSString *html = [render render];
        html = [NSString stringWithFormat:format,html];
        NSLog(@"%@",html);
        [_webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:path]];
    }
}

- (void)setupNav
{
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    self.navigationController.navigationBar.translucent = NO;
    UIImage *navBg = [UIImage imageWithColor:[UIColor colorWithRGBString:@"10eeee"] size:CGSizeMake(1000, 64)];
    [self.navigationController.navigationBar setBackgroundImage:[navBg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forBarMetrics:UIBarMetricsDefault];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"zzz");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"xxx");
}

@end
