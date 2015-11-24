//
//  TabBarController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "TabBarController.h"
#import "MenuViewController.h"
#import "FileManager.h"
#import "Item.h"

@interface UIViewController ()

@property (readonly) NSArray *rightItems;
@property (readonly) NSArray *leftItems;

@end

@interface TabBarController ()

@end

static TabBarController *tabVc = nil;

@implementation TabBarController
{
    Item *root;
}

+ (instancetype)currentViewContoller
{
    return tabVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tabVc = self;
    
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    FileManager *fm = [FileManager sharedManager];

    NSString *plistPath = [[NSString documentPath] stringByAppendingPathComponent:@"root.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        root = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
        fm.root = root;
    }else {
        FileManager *fm = [FileManager sharedManager];
        fm.workSpace = @"Root";
        root = fm.root;
        [root archive];
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
    NSArray *titles = @[@"MarkLite",@"文件",@"选项"];
    self.title = titles[self.selectedIndex];
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
