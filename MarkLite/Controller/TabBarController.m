//
//  TabBarController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "TabBarController.h"
#import "MenuViewController.h"
#import "ProjectViewController.h"

@interface TabBarController ()

@end

static TabBarController *tabVc = nil;
@implementation TabBarController

+ (instancetype)currentViewContoller
{
    return tabVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tabVc = self;
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if (!kIsPhone && [selectedViewController isKindOfClass:[MenuViewController class]]) {
       
        [self performSegueWithIdentifier:@"menu" sender:self];
        [self setSelectedIndex:self.selectedIndex];
        [self setSelectedViewController:self.selectedViewController];
        return;
    }
    [super setSelectedViewController:selectedViewController];
    self.title = selectedViewController.title;
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
