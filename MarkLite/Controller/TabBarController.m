//
//  TabBarController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "TabBarController.h"
#import "MenuViewController.h"

@interface UIViewController ()

@property (readonly) NSArray *rightItems;
@property (readonly) NSArray *leftItems;

@end

@interface TabBarController ()

@end

static TabBarController *tabVc = nil;

@implementation TabBarController
{
    NSArray *titles;
}


+ (instancetype)currentViewContoller
{
    return tabVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    tabVc = self;
    
    titles = @[ZHLS(@"TabTitle1"),ZHLS(@"TabTitle2"),ZHLS(@"TabTitle3")];
    for (int i = 0; i < self.tabBar.items.count; i ++) {
        self.tabBar.items[i].title = titles[i];
    }
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if ([selectedViewController respondsToSelector:@selector(rightItems)]) {
        self.navigationItem.rightBarButtonItems = selectedViewController.rightItems;
    }else{
        self.navigationItem.rightBarButtonItems = nil;
    }
    if ([selectedViewController respondsToSelector:@selector(leftItems)]) {
        self.navigationItem.leftBarButtonItems = selectedViewController.leftItems;
    }else{
        self.navigationItem.leftBarButtonItems = nil;
    }
    [super setSelectedViewController:selectedViewController];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} forState:UIControlStateNormal];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
