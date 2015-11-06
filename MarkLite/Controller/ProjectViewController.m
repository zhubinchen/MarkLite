//
//  ProjectViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "ProjectViewController.h"
#import "FileManager.h"
#import "CodeViewController.h"
#import "Item.h"
#import "FileItemCell.h"
#import "UserDefault.h"

@interface ProjectViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIViewControllerPreviewingDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (weak, nonatomic) IBOutlet UITableView *fileListView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ProjectViewController
{
    FileManager *fm;
    NSMutableArray *dataArray;
    Item *root;
    UserDefault *defaults;
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if ([self.presentedViewController isKindOfClass:[CodeViewController class]]) {
        return nil;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    return [sb instantiateViewControllerWithIdentifier:@"code"];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    // deep press: bring up the commit view controller (pop)
    [self showViewController:viewControllerToCommit sender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    if (kIsPhone) {
        self.title = @"代码";
        [self setupNav];
    } else {
        self.title = @"MarkLite";
        [self setupTabbar];
    }

    fm = [FileManager sharedManager];
    defaults = [UserDefault sharedDefault];
    
    if (defaults.oldUser) {
        NSDictionary *lastProject = [defaults projectHistory].lastObject;
        root = [self openWorkSpace:lastProject[@"name"]];
    } else {
        root = [self openWorkSpace:@"Template"];
        NSDictionary *project = @{@"name":@"Template"};
        [defaults addProject:project];
    }
    dataArray = root.itemsCanReach.mutableCopy;
    
}

- (Item*)openWorkSpace:(NSString *)name
{
    fm.workSpace = name;
    
    Item *ret = [[Item alloc]init];
    ret.name = name;
    ret.open = YES;
    
    for (NSString *name in fm.fileList) {
        Item *temp = [[Item alloc]init];
        temp.open = YES;
        temp.name = name;
        [ret addChild:temp];
    }
    dataArray = root.itemsCanReach.mutableCopy;

    return ret;
}

- (void)refresh
{
    dataArray = root.itemsCanReach.mutableCopy;
    [self.fileListView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileItemCell *cell = (FileItemCell*)[tableView dequeueReusableCellWithIdentifier:@"fileItemCell" forIndexPath:indexPath];
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
    {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    Item *item = dataArray[indexPath.row];
    cell.item = item;
    cell.onAdd = ^(){
        
    };
    
    cell.onTrash = ^(){
        [item removeFromParent];
        [self refresh];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *i = dataArray[indexPath.row];
    
    if (i.folder) {
        if (!i.open) {
            i.open = YES;
            [self openWithIndex:(int)indexPath.row];
        }else{
            [self foldWithIndex:(int)indexPath.row];
            i.open = NO;
        }
        return;
    }
    
    [fm openFile:i.name];
    
    if (kIsPhone) {
        [self performSegueWithIdentifier:@"code" sender:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFile" object:nil];
    }
}

- (void)foldWithIndex:(int)index
{
    NSArray *children = [dataArray[index] itemsCanReach];
    [dataArray removeObjectsInArray:children];

    [self.fileListView beginUpdates];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < children.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+i+1 inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [self.fileListView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    
    [self.fileListView endUpdates];
}

- (void)openWithIndex:(int)index
{
    NSArray *children = [dataArray[index] itemsCanReach];
    [dataArray insertObjects:children atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, children.count)]];

    [self.fileListView beginUpdates];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < children.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+i+1 inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [self.fileListView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    
    [self.fileListView endUpdates];
}

- (void)setupTabbar
{
    UITabBarItem *new = [[UITabBarItem alloc]initWithTitle:@"新建" image:[[UIImage imageNamed:@"New"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:0];
    
    UITabBarItem *history = [[UITabBarItem alloc]initWithTitle:@"历史" image:[[UIImage imageNamed:@"History"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:0];
    
    [new setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} forState:UIControlStateNormal];
    
    [history setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} forState:UIControlStateNormal];
    
    self.tabBar.items = @[new,history];
}

- (void)setupNav
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newProject)];
}

- (void)newProject
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"新建工程" message:@"请输入工程名" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)historyProject
{
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *name = [alertView textFieldAtIndex:0].text;
        root = [self openWorkSpace:name];
        NSDictionary *project = @{@"name":name};
        [defaults addProject:project];
        dataArray = root.itemsCanReach;
    }
    
    [self refresh];
}

@end
