//
//  PreviewViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-28.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "PreviewViewController.h"
#import "FileManager.h"
#import "GHMarkdownParser.h"

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
    NSString *title = [[FileManager sharedManager].currentFilePath componentsSeparatedByString:@"/"].lastObject;
    if (title) {
        self.title = [title stringByDeletingPathExtension];
    }
}

- (IBAction)back:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *path = [FileManager sharedManager].currentFilePath;
    NSLog(@"%@",path);
    NSString *markDown = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *formatHtmlFile = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
    NSString *format = [NSString stringWithContentsOfFile:formatHtmlFile encoding:NSUTF8StringEncoding error:nil];
    GHMarkdownParser *parser = [[GHMarkdownParser alloc] init];
    parser.options = kGHMarkdownAutoLink; // for example
    parser.githubFlavored = YES;
    NSString *html = [parser HTMLStringFromMarkdownString:markDown];
    html = [NSString stringWithFormat:format,html];
    [_webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:path]];
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
