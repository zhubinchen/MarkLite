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
#import "User.h"

@interface UIViewController ()

@property (readonly) NSArray *rightItems;
@property (readonly) NSArray *leftItems;

@end

@interface TabBarController ()

@property (nonatomic,strong) Item *root;

@end

static TabBarController *tabVc = nil;

@implementation TabBarController
{
    NSMutableArray *itemsToDownload;
}

+ (instancetype)currentViewContoller
{
    return tabVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    
    tabVc = self;

    itemsToDownload = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:@"ItemsChangedNotification" object:nil];
}

- (void)update:(NSNotification*)noti
{
    _root.needUpdate = YES;
    [_root archive];
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
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} forState:UIControlStateNormal];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
