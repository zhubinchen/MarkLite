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
#import "FileSyncManager.h"
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
    
    [self initializeWorkSapce];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:@"RootNeedSaveChange" object:nil];
}

- (void)initializeWorkSapce
{
    FileManager *fm = [FileManager sharedManager];
    
    NSString *plistPath = [[NSString documentPath] stringByAppendingPathComponent:@"root.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        _root = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
        fm.root = _root;
    }else if ([User currentUser].hasLogin) {
        beginLoadingAnimation(@"正在同步...");
        [[FileSyncManager sharedManager] rootFromServer:^(Item *item,int error) {
            if (item) {
                _root = item;
                fm.root = _root;
                [self createFile];
                [_root archive];
            }else{
                if (error == 1) {
                    FileManager *fm = [FileManager sharedManager];
                    [fm initWorkSpace];
                    _root = fm.root;
                    [_root archive];
                }else{
                    showToast(@"同步失败，请检查网络后重试");
                }
            }
            [self.viewControllers.firstObject reload];
            stopLoadingAnimation();
        }];
    }else{
        FileManager *fm = [FileManager sharedManager];
        [fm initWorkSpace];
        _root = fm.root;
        [_root archive];
    }
}

- (void)createFile
{
    FileManager *fm = [FileManager sharedManager];
    [fm createFolder:_root.path];
    for (Item *i in _root.items) {
        if (i.syncStatus != SyncStatusUnDownload) {
            continue;
        }
        if (i.type == FileTypeFolder) {
            [fm createFolder:i.path];
            i.syncStatus = SyncStatusSuccess;
        }else{
            [itemsToDownload addObject:i];
        }
    }
    
    [self download];
}

- (void)download
{
    Item *i = itemsToDownload.firstObject;
    if (i == nil) {
        return;
    }
    [[FileSyncManager sharedManager]downloadFile:i.path progressHandler:^(float percent) {
        NSLog(@"%.2f",percent);
    } result:^(BOOL success, NSData *data) {
        [itemsToDownload removeObject:i];
        if (success) {
            i.syncStatus = SyncStatusSuccess;
            [[FileManager sharedManager] createFile:i.path Content:data];
        }
        [self download];
    }];
}

- (void)update:(NSNotification*)noti
{
    _root.needUpdate = YES;
    [_root archive];

    if ([User currentUser].hasLogin) {
        [[FileSyncManager sharedManager]update:^(BOOL success) {
            if (success) {
                _root.needUpdate = NO;
                [_root archive];
            }
        }];
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
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} forState:UIControlStateNormal];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
