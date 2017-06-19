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
{
    CAGradientLayer *layer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    if (layer == nil) {
        layer = [CAGradientLayer new];
        layer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1].CGColor;
        [self.view.layer insertSublayer:layer atIndex:0];
    }
    layer.frame = self.view.bounds;
}

@end
