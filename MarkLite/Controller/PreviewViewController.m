//
//  PreviewViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-28.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "PreviewViewController.h"
#import "StyleViewController.h"
#import "FileManager.h"
#import "HoedownHelper.h"
#import "Item.h"
#import "Configure.h"
#import "ZHUtils.h"
#import "PDFPageRender.h"

@interface PreviewViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;

@end

@implementation PreviewViewController
{
    Item *item;
    FileManager *fm;
    NSString *htmlString;
    UIPopoverPresentationController *popVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    fm = [FileManager sharedManager];
   
    if (kDevicePad) {
        [fm addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:NULL];
    }
    [[Configure sharedConfigure] addObserver:self forKeyPath:@"style" options:NSKeyValueObservingOptionNew context:NULL];
    UIBarButtonItem *styleBtn = [[UIBarButtonItem alloc]initWithTitle:ZHLS(@"Style") style:UIBarButtonItemStylePlain target:self action:@selector(style)];
    UIBarButtonItem *exportBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"export"] style:UIBarButtonItemStylePlain target:self action:@selector(export)];
    self.navigationItem.rightBarButtonItems = @[exportBtn,styleBtn];

    _webView.delegate = self;
}

- (void)viewDidLayoutSubviews
{
    if (item == nil) {
        [self loadFile];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"style"]) {
        [self loadFile];
        return;
    }
    if (item && [change[@"new"] isEqual:item]) {
        return;
    }
    [self loadFile];
}

- (void)loadFile
{
    item = fm.currentItem;
    if (item == nil) {
        self.title = @"";
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [_webView loadHTMLString:@"" baseURL:nil];
        return;
    }
    self.title = item.name;
    
    NSString *path = item.fullPath;
    
    _webView.hidden = NO;
    _imageView.hidden = YES;
    
    beginLoadingAnimationOnParent(ZHLS(@"Loading"), self.webView);
    
    dispatch_async(dispatch_queue_create("preview_queue", DISPATCH_QUEUE_CONCURRENT), ^{
        hoedown_renderer *render = CreateHTMLRenderer();
        NSString *markdown = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *html = HTMLFromMarkdown(markdown, HOEDOWN_EXT_BLOCK|HOEDOWN_EXT_SPAN|HOEDOWN_EXT_FLAGS, YES, @"", render, CreateHTMLTOCRenderer());
        NSString *formatHtmlFile = [[NSBundle mainBundle] pathForResource:@"format" ofType:@"html"];
        NSString *format = [NSString stringWithContentsOfFile:formatHtmlFile encoding:NSUTF8StringEncoding error:nil];
        
        
        NSString *styleFile = [[NSBundle mainBundle] pathForResource:[Configure sharedConfigure].style ofType:@"css"];
        NSString *style = [NSString stringWithContentsOfFile:styleFile encoding:NSUTF8StringEncoding error:nil];
        htmlString = [[format stringByReplacingOccurrencesOfString:@"#_html_place_holder_#" withString:html] stringByReplacingOccurrencesOfString:@"#_style_place_holder_#" withString:style];
        dispatch_async(dispatch_get_main_queue(), ^{
            _webView.scalesPageToFit = NO;
            NSLog(@"%@",htmlString);
            [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:path]];
        });
    });
}

- (void)style
{
    UIViewController *vc = [[StyleViewController alloc]init];
    vc.title = ZHLS(@"Style");
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:nav animated:YES completion:nil];
}

- (void)export
{
    void(^clickedBlock)(NSInteger) = ^(NSInteger index) {
        NSURL *url = nil;
        if (index == (kDevicePad ? 1 : 0)){
            url = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"/temp/%@.html",[fm currentItem].name]]];
            if (htmlString) {
                [htmlString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }else if(index == (kDevicePad ? 2 : 1)){
            url = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"/temp/%@.pdf",[fm currentItem].name]]];
            
            NSData *data = [self createPDF];
            [data writeToURL:url atomically:YES];
        }else if(index == (kDevicePad ? 3 : 2)){
            url = [NSURL fileURLWithPath:item.fullPath];
        }
        if (url) {
            [self exportFile:url];
        }
    };
    if (kDevicePad) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"ExportAs") message:nil delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"WebPage"),ZHLS(@"PDF"),ZHLS(@"Markdown"), nil];
        alert.clickedButton = clickedBlock;
        [alert show];
    }else{
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:ZHLS(@"ExportAs") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:ZHLS(@"WebPage"),ZHLS(@"PDF"),ZHLS(@"Markdown"), nil];
        sheet.clickedButton = clickedBlock;
        [sheet showInView:self.view];
    }
}

- (void)exportFile:(NSURL*)url
{
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr
                                    ];
    controller.excludedActivityTypes = excludedActivities;
    
    if (kDevicePad) {
        popVc = controller.popoverPresentationController;
        popVc.barButtonItem = self.navigationItem.rightBarButtonItem;
        popVc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

- (NSData*)createPDF{
    
    PDFPageRender *render = [[PDFPageRender alloc]init];
    return [render renderPDFFromHtmlString:htmlString];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    stopLoadingAnimationOnParent(self.webView);
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    stopLoadingAnimationOnParent(self.webView);
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)dealloc
{
    if (kDevicePad) {
        [fm removeObserver:self forKeyPath:@"currentItem" context:NULL];
    }
    [[Configure sharedConfigure] removeObserver:self forKeyPath:@"style" context:NULL];
    
    [Configure sharedConfigure].useTimes += 1;
    
    if (![ZHLS(@"About") isEqualToString:@"关于"]) {
        return;
    }
    
    if ([Configure sharedConfigure].useTimes == 15 && ![Configure sharedConfigure].hasRated) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry，打扰一下，请问在您使用的这段时间里，您对MarkLite的印象如何？有什么需要改进的？" message:nil delegate:nil cancelButtonTitle:@"暂时没空" otherButtonTitles:@"赏个好评", @"提个意见", nil];
        alert.clickedButton = ^(NSInteger index){
            if (index == 1) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
                [Configure sharedConfigure].hasRated = YES;
            }else if (index == 2){
                NSString *url = @"mailto:cheng4741@gmail.com?subject=MarkLite%20Report&body=";
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
                [Configure sharedConfigure].hasRated = YES;
            }
        };
        [alert show];
        [Configure sharedConfigure].useTimes = 0;
    }
}

@end
