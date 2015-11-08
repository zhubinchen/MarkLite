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

@interface ProjectViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIViewControllerPreviewingDelegate,UISearchBarDelegate>
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

#pragma mark 3dTouch

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if ([self.presentedViewController isKindOfClass:[CodeViewController class]]) {
        return nil;
    }
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    return [sb instantiateViewControllerWithIdentifier:@"code"];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
        
    if (kIsPhone) {
        self.title = @"代码";
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

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newProject)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

#pragma mark 功能逻辑

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


- (void)addFileWithParent:(Item*)parent
{
    int index = 0;
    for (Item *i in dataArray) {
        index ++;
        if (i == parent) {
            break;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"新建文件或目录" message:@"请输入文件或目录名，如创建文件应输入文件类型" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
        if (buttonIndex == 0) {
            NSString *name = [alert textFieldAtIndex:0].text;
            NSString *path = [parent.name stringByAppendingPathComponent:name];
            Item *i = [[Item alloc]init];
            i.name = path;
            i.open = YES;
            if (i.folder) {
                [fm createFolder:path];
            }else{
                [fm createFile:path Content:[NSData data]];
            }
            
            [parent addChild:i];
            [dataArray insertObject:i atIndex:0];
            
            dataArray = root.itemsCanReach.mutableCopy;
            [self.fileListView reloadData];
        }
    };
    [alert show];
}

- (void)newProject
{
    [self addFileWithParent:root];
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *i = dataArray[indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定要删除该文件？" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
        if (buttonIndex == 0) {
            [i removeFromParent];
            NSArray *children = [i itemsCanReach];
            [dataArray removeObjectsInArray:children];
            [dataArray removeObject:i];
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i = 0; i < children.count +1; i++) {
                NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row+i inSection:0];
                [indexPaths addObject:index];
            }
            
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
            [fm deleteFile:i.name];
        }
        [alert releaseBlock];
    };
    [alert show];
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
        [self addFileWithParent:item];
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

- (void)setupTabbar
{
    UITabBarItem *new = [[UITabBarItem alloc]initWithTitle:@"新建" image:[[UIImage imageNamed:@"New"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:0];
    
    UITabBarItem *history = [[UITabBarItem alloc]initWithTitle:@"历史" image:[[UIImage imageNamed:@"History"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] tag:0];
    
    [new setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} forState:UIControlStateNormal];
    
    [history setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} forState:UIControlStateNormal];
    
    self.tabBar.items = @[new,history];
}

@end
