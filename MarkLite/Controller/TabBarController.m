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

@property (nonatomic,strong) Item *root;

@end

static TabBarController *tabVc = nil;

@implementation TabBarController


+ (instancetype)currentViewContoller
{
    return tabVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;

    tabVc = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:@"ItemsChangedNotification" object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self star];
    });
}

- (void)star
{
    BOOL hasStared = [[NSUserDefaults standardUserDefaults] boolForKey:@"has_stared"];
    if (hasStared) {
        return;
    }
    
    NSDate *last = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_alert"];
    NSDate *now = [NSDate date];
    

    if (last == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"last_alert"];
        return;
    }
    
    if ([now timeIntervalSinceDate:last] < 60*60*24) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"谢谢你的使用，如果觉得不错，请给个好评鼓励一下吧😍" message:@"" delegate:nil cancelButtonTitle:@"好评鼓励" otherButtonTitles:@"别再打扰我",@"以后再说", nil];
    alert.clickedButton = ^(NSInteger index,UIAlertView *alert){
        if (index == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"has_stared"];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        }else if (index == 1) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"has_stared"];
        }
    };
    [alert show];
    
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"last_alert"];
}


- (void)update:(NSNotification*)noti
{
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
