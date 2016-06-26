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

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;

@end

@implementation PreviewViewController
{
    FileManager *fm;
    NSString *htmlString;
    UIActivityIndicatorView *indicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
    NSString *path = [fm localPath:[fm currentItem].path];

    
    if (fm.currentItem.type == FileTypeImage) {
        _webView.hidden = YES;
        _imageView.hidden = NO;
        self.navigationItem.rightBarButtonItem = nil;
        UIImage *image = [[UIImage imageWithContentsOfFile:path] scaleWithMaxSize:self.view.bounds.size];
        _imageView.image = image;
        _width.constant = image.size.width;
        _height.constant = image.size.height;
        [self.view updateConstraintsIfNeeded];
    }else{
        _webView.hidden = NO;
        _imageView.hidden = YES;
        indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = self.view.center;
        indicator.hidesWhenStopped = YES;
        [indicator startAnimating];
        [self.view addSubview:indicator];
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
                [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:path]];
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"export"] style:UIBarButtonItemStylePlain target:self action:@selector(export)];
            });
        });
    }
}

- (void)export
{
    NSURL *url = [NSURL fileURLWithPath:[documentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html",[fm currentItem].name]]];
    if (htmlString) {
        [htmlString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }

    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    //    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
    //                                    UIActivityTypePostToWeibo,
    //                                    UIActivityTypeMessage, UIActivityTypeMail,
    //                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
    //                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
    //                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
    //                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    //    controller.excludedActivityTypes = excludedActivities;
    
    if (kDevicePhone) {
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        UIPopoverPresentationController *vc = controller.popoverPresentationController;
        vc.barButtonItem = self.navigationItem.rightBarButtonItem;
//        vc.sourceRect = view.bounds;
        vc.permittedArrowDirections = UIPopoverArrowDirectionAny;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{

}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [indicator stopAnimating];
}

- (void)dealloc
{
    if (kDevicePad) {
        [fm removeObserver:self forKeyPath:@"currentItem" context:NULL];
    }
}

@end
