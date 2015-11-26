//
//  FileListViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "FileListViewController.h"
#import "FileManager.h"
#import "EditViewController.h"
#import "PreviewViewController.h"
#import "Item.h"
#import "FileItemCell.h"
#import "Configure.h"

@interface FileListViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIViewControllerPreviewingDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *fileListView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FileListViewController
{
    Item *root;
    FileManager *fm;

    BOOL trash;
    
    NSMutableArray *dataArray;
    UIBarButtonItem *rightItem;
    UIBarButtonItem *leftItem;
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    fm = [FileManager sharedManager];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recievedNotification:) name:@"launchFormShortCutItem" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    root = fm.root;
    dataArray = root.itemsCanReach.mutableCopy;
    [self.fileListView reloadData];
}

- (NSArray*)rightItems
{
    rightItem = [[UIBarButtonItem alloc]initWithTitle:@"废纸篓" style:UIBarButtonItemStylePlain target:self action:@selector(goToTrash)];
    return @[rightItem];
}

- (void)goToTrash
{
    trash = !trash;
    rightItem.title = trash ? @"所有文件" : @"废纸篓";
    [self.fileListView reloadData];
}


#pragma mark 功能逻辑

- (void)recievedNotification:(NSNotification*)noti
{
    NSDictionary *dic = [Configure sharedConfigure].launchOptions;
    if ([dic[@"type"] isEqualToString:@"new"]) {
        [self newProject];
    }else if ([dic[@"type"] isEqualToString:@"open"]) {
        for (Item *i in root.children) {
            if ([i.path isEqualToString:dic[@"path"]]) {
                fm.currentItem = i;
                break;
            }
        }
        
        [self performSegueWithIdentifier:@"code" sender:self];
    }
}

- (void)foldWithIndex:(int)index
{
    NSArray *children;
    if (self.searchBar.text.length) {
        children = [dataArray[index] searchResult:self.searchBar.text];
    }else{
        children = [dataArray[index] itemsCanReach];
    }
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
    NSArray *children;
    if (self.searchBar.text.length) {
        children = [dataArray[index] searchResult:self.searchBar.text];
    }else{
        children = [dataArray[index] itemsCanReach];
    }
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
    
    if (SYSTEM_VERSION >= 8.0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新建文件或文件夹" message:@"如果创建文件应输入文件扩展名（如 readme.md）" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *name = alert.textFields[0].text;
            if (name.length < 1) {
                return ;
            }
            NSString *path = [parent.path stringByAppendingPathComponent:name];
            Item *i = [[Item alloc]init];
            i.path = path;
            i.open = YES;
            if (i.type == FileTypeFolder) {
                [fm createFolder:path];
            }else{
                [fm createFile:path Content:[NSData data]];
            }
            
            [parent addChild:i];
            
            dataArray = root.itemsCanReach.mutableCopy;
            [self.fileListView reloadData];
            
            if (i.type == FileTypeText) {
                fm.currentItem = i;
                [self performSegueWithIdentifier:@"code" sender:self];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"新建文件或文件夹" message:@"如果创建文件应输入文件扩展名（如 readme.md）" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
            if (buttonIndex == 1) {
                [[alert textFieldAtIndex:0] resignFirstResponder];
                NSString *name = [alert textFieldAtIndex:0].text;
                NSString *path = [parent.path stringByAppendingPathComponent:name];
                Item *i = [[Item alloc]init];
                i.path = path;
                i.open = YES;
                if (i.type == FileTypeFolder) {
                    [fm createFolder:path];
                }else{
                    [fm createFile:path Content:[NSData data]];
                }
                
                [parent addChild:i];
                
                dataArray = root.itemsCanReach.mutableCopy;
                [self.fileListView reloadData];
                
                if (i.type == FileTypeText) {
                    fm.currentItem = i;
                    [self performSegueWithIdentifier:@"code" sender:self];
                }
            }
        };
        [alert show];
    }
}

- (void)newProject
{
    [self addFileWithParent:root];
}

- (void)searchWithWord:(NSString*)word
{
    if (word.length == 0) {
        dataArray = root.itemsCanReach.mutableCopy;
    }else {
        dataArray = [root searchResult:word].mutableCopy;
    }
    [self.fileListView reloadData];
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
            [fm deleteFile:i.path];
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
    cell.newFileBlock = ^(){
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

    if (i.type == FileTypeFolder) {
        if (!i.open) {
            i.open = YES;
            [self openWithIndex:(int)indexPath.row];
        }else{
            [self foldWithIndex:(int)indexPath.row];
            i.open = NO;
        }
        FileItemCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.item = i;
        return;
    }
    
    fm.currentItem = i;
    
    if (i.type == FileTypeImage) {
        [self performSegueWithIdentifier:@"preview" sender:self];
    }else {
        [self performSegueWithIdentifier:@"code" sender:self];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchWithWord:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    [self searchWithWord:@""];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    [searchBar setCancelButtonTitle:@"取消"];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

#pragma mark 3dTouch

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if ([self.presentedViewController isKindOfClass:[EditViewController class]]) {
        return nil;
    }
    FileItemCell *cell = (FileItemCell*)[previewingContext sourceView];
    fm.currentItem = cell.item;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    if (cell.item.type == FileTypeImage) {
        return [sb instantiateViewControllerWithIdentifier:@"preview"];
    }
    EditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"code"];
    vc.projectVc = self;
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}


@end
