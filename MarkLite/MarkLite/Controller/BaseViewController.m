//
//  BaseViewController.m
//  MarkLite
//
//  Created by Bingcheng on 11/23/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];


//    self.view.borderRadius = 15;
//    self.view.borderColor = kPrimaryColor;
//    self.parentViewController.view.backgroundColor = kPrimaryColor;
//    self.navigationController.navigationBar.shadowImage = [UIImage alloc];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

- (void)back
{
    if ([self shouldPopBack]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)shouldPopBack
{
    return YES;
}

- (void)viewDidLayoutSubviews
{
    CAGradientLayer *layer = [CAGradientLayer new];
    layer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1].CGColor;
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
}

@end
