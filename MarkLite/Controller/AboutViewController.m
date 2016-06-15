//
//  AboutViewController.m
//  MarkLite
//
//  Created by zhubch on 4/1/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"关于";
    
    NSString *htmlStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"about" ofType:@"html" ]encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlStr baseURL:nil];
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.scrollView.bounces = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
