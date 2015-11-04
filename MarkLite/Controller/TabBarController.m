//
//  TabBarController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "TabBarController.h"
#import "MenuViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [self setupNav];
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

- (void)setupNav
{
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
