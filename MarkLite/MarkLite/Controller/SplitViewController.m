//
//  SplitViewController.m
//  MarkLite
//
//  Created by Bingcheng on 1/25/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "SplitViewController.h"
#import "EditViewController.h"

@interface SplitViewController () <UISplitViewControllerDelegate>

@end

@implementation SplitViewController
{
    UIPopoverController *popVc;
    EditViewController *editVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;

}

- (void)viewDidLayoutSubviews
{
    CAGradientLayer *layer = [CAGradientLayer new];
    layer.colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:1].CGColor, (__bridge id)[UIColor colorWithWhite:0.95 alpha:1].CGColor];
    layer.startPoint = CGPointMake(0, kWindowHeight);
    layer.endPoint = CGPointMake(kWindowWidth, 0);
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
}

- (void)show
{
    UIViewController *master = self.viewControllers[0];
    UIViewController *detail = self.viewControllers[1];
    NSLog(@"%@",NSStringFromCGRect(master.view.frame));
    NSLog(@"%@",NSStringFromCGRect(detail.view.frame));

    detail.view.frame = CGRectMake(0, 0, kWindowWidth, kWindowHeight);
}

- (void)hide
{

}

@end
