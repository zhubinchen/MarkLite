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
#import "ChooseFolderViewController.h"
#import "Item.h"
#import "FileItemCell.h"
#import "Configure.h"
#import "CreateFileView.h"

@interface FileListViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIViewControllerPreviewingDelegate,UISearchBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MGSwipeTableCellDelegate,CreateFileViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *localListView;
@property (weak, nonatomic) IBOutlet UITableView *cloudListView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic) BOOL cloud;
@property (strong, nonatomic) FileManager *fm;
@property (strong, nonatomic) UIView *toolBar;

@end

@implementation FileListViewController
{
    Item *root;
    Item *selectParent;
    Item *selectItem;
    BOOL edit;

    NSMutableArray *dataArray;
    UIBarButtonItem *rightItem;
    UIBarButtonItem *leftItem;
    UIPopoverPresentationController *popVc;
    UITableView *fileListView;
    UISegmentedControl *segment;
    CreateFileView *createView;
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    _fm = [FileManager sharedManager];
    
    self.cloud = NO;
    [self.localListView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:@"file"];
    [self.cloudListView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:@"file"];
    self.searchBar.placeholder = ZHLS(@"Search");
    [self reload];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:kFileChangedNotificationName object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title = ZHLS(self.cloud?@"NavTitleCloudFile":@"NavTitleLocalFile");
}

- (void)toggleCloud
{
    [self dismissView:createView];
    if (edit) {
        if ([leftItem.title isEqualToString:ZHLS(@"SelectAll")]) {
            root.selected = YES;
        }else{
            for (Item *i in root.items) {
                i.selected = !i.selected;
            }
            root.selected = NO;
        }
        leftItem.title = ZHLS(root.selected ? @"Inverse":@"SelectAll");
        return;
    }
    self.cloud = !self.cloud;
    self.tabBarController.title = ZHLS(self.cloud?@"NavTitleCloudFile":@"NavTitleLocalFile");
    leftItem.title = ZHLS(self.cloud?@"NavTitleLocalFile":@"NavTitleCloudFile");
}

- (void)setCloud:(BOOL)cloud
{
    _cloud = cloud;
    [self reload];
    self.view.backgroundColor = [UIColor whiteColor];
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
    [UIView commitAnimations];
}

- (void)reload
{
    _cloud ? [_fm createCloudWorkspace] : [_fm createLocalWorkspace];
    
    root = _cloud ? _fm.cloud : _fm.local;
    dataArray = root.itemsCanReach.mutableCopy;
    fileListView = _cloud ? _cloudListView : _localListView;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_fm.currentItem.fullPath]) {
        _fm.currentItem = nil;
    }
    stopLoadingAnimationOnParent(self.view);
    [fileListView reloadData];
}

- (UIView *)toolBar
{
    if (_toolBar == nil) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 49)];
        _toolBar.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [uploadBtn setImage:[UIImage imageNamed:@"export"] forState:UIControlStateNormal];
        uploadBtn.frame = CGRectMake(10, 9, 30, 30);
        [uploadBtn addTarget:self action:@selector(uploadSelectedItems:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:uploadBtn];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        deleteBtn.frame = CGRectMake(self.view.bounds.size.width - 40, 9, 30, 30);
        [deleteBtn addTarget:self action:@selector(deleteSelectedItems) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:deleteBtn];
        
        UIButton *moveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [moveBtn setTitleColor:[UIColor colorWithRGBString:@"007aff"] forState:UIControlStateNormal];
        moveBtn.frame = CGRectMake(self.view.bounds.size.width / 2 - 50, 10, 100, 29);
        moveBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [moveBtn addTarget:self action:@selector(moveSelectedItems) forControlEvents:UIControlEventTouchUpInside];
        [moveBtn setTitle:ZHLS(@"Move") forState:UIControlStateNormal];
        [_toolBar addSubview:moveBtn];
    }

    return _toolBar;
}

- (void)uploadSelectedItems:(UIButton*)sender
{
    [self export:root.selectedChildren sourceView:sender];
}

- (void)deleteSelectedItems
{
    [self deleteItems:root.selectedChildren];
}

- (void)moveSelectedItems
{
    [self performSegueWithIdentifier:@"chooseFolder" sender:self];
}

- (NSArray*)rightItems
{
    rightItem = [[UIBarButtonItem alloc]initWithTitle:ZHLS(edit ? @"Done":@"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    UIBarButtonItem *new = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newNote)];
    return @[new,rightItem];
}

- (NSArray*)leftItems
{
    leftItem = [[UIBarButtonItem alloc]initWithTitle:ZHLS(self.cloud?@"NavTitleLocalFile":@"NavTitleCloudFile") style:UIBarButtonItemStylePlain target:self action:@selector(toggleCloud)];
    return @[leftItem];
}

- (void)newNote
{
    CGFloat w = self.view.bounds.size.width;
    
    if (createView.superview) {
        [self dismissView:createView];
        return;
    }
    createView = [CreateFileView instance];
    
    if ([Configure sharedConfigure].defaultParent == nil) {
        [Configure sharedConfigure].defaultParent = _fm.local;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[Configure sharedConfigure].defaultParent.fullPath]) {
        [Configure sharedConfigure].defaultParent = _fm.local;
    }
    createView.parent = [Configure sharedConfigure].defaultParent;
    createView.delegate = self;
    createView.frame = CGRectMake(0, -140, w, 140);
    [self showView:createView];
}

- (void)dismissView:(UIView*)v
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIView *control = v.superview;
    
    if ([v isKindOfClass:[UIControl class]]) {
        control = v;
        v = control.subviews.firstObject;
    }
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = v.frame.size.height;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        v.frame = CGRectMake(0, 44 + statusBarHeight - h, w, h);
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        if (finished) {
            [v removeFromSuperview];
            [control removeFromSuperview];
        }
    }];
}

- (void)showView:(UIView*)v
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIControl *control = [[UIControl alloc]initWithFrame:self.view.bounds];
    control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [control addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    
    control.frame = self.view.bounds;
    [self.view addSubview:control];
    [control addSubview:v];
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = v.frame.size.height;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        v.frame = CGRectMake(0, 44 + statusBarHeight, w, h);
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    } completion:^(BOOL finished) {
    }];
}

- (void)edit
{
    [self dismissView:createView];
    edit = !edit;

    if (edit) {
        leftItem.title = ZHLS(root.selected ? @"Inverse":@"SelectAll");
        rightItem.title = ZHLS(@"Done");
        [self.tabBarController.tabBar addSubview:self.toolBar];
    }else{
        leftItem.title = ZHLS(self.cloud ? @"NavTitleLocalFile":@"NavTitleCloudFile");
        rightItem.title = ZHLS(@"Edit");
        [self.toolBar removeFromSuperview];
    }
    [fileListView reloadData];
}

#pragma mark CreatFileViewDelegate

- (void)didCancel:(CreateFileView *)view
{
    [self dismissView:view];
}

- (void)createFileView:(CreateFileView *)view didCreateItem:(Item *)item
{
    [self dismissView:view];
    [self reload];
    
    if (item.type == FileTypeFolder) {
        return;
    }
    _fm.currentItem = item;
    if (kDevicePhone) {
        [self performSegueWithIdentifier:@"edit" sender:self];
    }
    
}

- (void)shouldChooseParent:(CreateFileView *)view
{
    [self performSegueWithIdentifier:@"chooseFolder" sender:self];
}

#pragma mark 显示控制

- (void)foldWithIndex:(int)index
{
    NSArray *children;
    if (self.searchBar.text.length) {
        children = [dataArray[index] searchResult:self.searchBar.text];
    }else{
        children = [dataArray[index] itemsCanReach];
    }
    [dataArray removeObjectsInArray:children];

    [fileListView beginUpdates];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < children.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+i+1 inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [fileListView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    
    [fileListView endUpdates];
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
    
    [fileListView beginUpdates];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < children.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+i+1 inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [fileListView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    
    [fileListView endUpdates];
}

- (void)searchWithWord:(NSString*)word
{
    if (word.length == 0) {
        dataArray = root.itemsCanReach.mutableCopy;
    }else {
        dataArray = [root searchResult:word].mutableCopy;
    }
    [fileListView reloadData];
}

#pragma mark MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    Item *i = [(FileItemCell*)cell item];
    if (index == 0) {
        [self deleteItems:@[i]];
    }else if (index == 1){
        [self renameItem:i];
    }else{
        [self export:@[i] sourceView:cell];
    }
    return YES;
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point
{
    return !edit;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FileItemCell *cell = (FileItemCell*)[tableView dequeueReusableCellWithIdentifier:@"file" forIndexPath:indexPath];
    cell.delegate = self;
    Item *item = dataArray[indexPath.row];
    cell.item = item;
    cell.checkBtn.hidden = !edit;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    
    _fm.currentItem = i;
    
    if (kDevicePhone && !edit) {
        [self performSegueWithIdentifier:@"edit" sender:self];
    }
}

#pragma mark searchbar

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
    [searchBar setCancelButtonTitle:ZHLS(@"Cancel")];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:ZHLS(@"chooseFolder")]) {
        ChooseFolderViewController *vc = [(UINavigationController*)segue.destinationViewController viewControllers].firstObject;
        vc.didChoosedFolder = ^(Item *i){
            if (edit) {
                [self moveItems:root.selectedChildren toParent:i];
            }else{
                createView.parent = i;
                [Configure sharedConfigure].defaultParent = i;
            }
        };

    }
}

#pragma mark 文件操作

- (NSURL *)fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}

- (void)export:(NSArray<Item *>*) items sourceView:(UIView*)view{
    NSMutableArray *urls = [NSMutableArray array];
    
    for (Item *i in items) {
        if (i.type == FileTypeFolder) {
            continue;
        }
        NSURL *url = [NSURL fileURLWithPath:i.fullPath];
        [urls addObject:url];
    }
    NSArray *objectsToShare = urls;
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr
                                    ];
    controller.excludedActivityTypes = excludedActivities;
    
    if (kDevicePhone) {
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        popVc = controller.popoverPresentationController;
        popVc.sourceView = view;
        popVc.sourceRect = view.bounds;
        popVc.permittedArrowDirections = UIPopoverArrowDirectionAny;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:controller animated:YES completion:nil];
        });
    }
    
}

- (void)renameItem:(Item*)i
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"Rename") message:ZHLS(@"NamePlaceholder") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].text = i.name;
    __weak UIAlertView *__alert = alert;
    alert.clickedButton = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {
            NSString *name = [__alert textFieldAtIndex:0].text;
            name = [name componentsSeparatedByString:@"."].firstObject;
            if (name.length == 0) {
                showToast(ZHLS(@"EmptyNameTips"));
                return ;
            }
            if ([name containsString:@"/"] || [name containsString:@"*"]) {
                showToast(ZHLS(@"InvalidName"));
                return;
            }
            NSString *oldPath = i.path;
            NSString *newPath = [i.path stringByReplacingOccurrencesOfString:i.name withString:name];
            NSString *oldFullPath = i.fullPath;
            i.path = newPath;
            NSString *newFullPath = i.fullPath;
            
            if ([_fm moveFile:oldFullPath toNewPath:newFullPath]) {
                [fileListView reloadData];
            }else{
                i.path = oldPath;
                showToast(ZHLS(@"DuplicateError"));
            }
        }
        
    };
    [alert show];
}

- (void)addFileWithParent:(Item*)parent
{
    selectParent = parent;
    
    int index = 0;
    for (Item *i in dataArray) {
        index ++;
        if (i == parent) {
            break;
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ZHLS(@"ChooseYourOperation") message:nil delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"NewMarkdownFile"),ZHLS(@"NewFolder"), nil];
    alert.clickedButton = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {
            [self createFileWithType:FileTypeText];
        }else if (buttonIndex == 2) {
            [self createFileWithType:FileTypeFolder];
        }
    };
    [alert show];
}

- (void)createFileWithType:(FileType)type
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:type == FileTypeText ? ZHLS(@"FileNameAlertTitle") : ZHLS(@"FolderNameAlertTitle") message:ZHLS(@"NameAlertMessage") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    __weak UIAlertView *__alert = alert;
    alert.clickedButton = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {
            [[__alert textFieldAtIndex:0] resignFirstResponder];
            NSString *name = [__alert textFieldAtIndex:0].text;
            if (name.length == 0) {
                name = ZHLS(@"Untitled");
            }
            if (type == FileTypeText) {
                name = [name stringByAppendingString:@".md"];
            }
            NSString *path = name;
            if (!selectParent.root) {
                path = [selectParent.path stringByAppendingPathComponent:name];
            }
            Item *i = [[Item alloc]init];
            i.path = path;
            i.open = YES;
            i.cloud = selectParent.cloud;
            
            NSString *ret = nil;
            if (i.type == FileTypeFolder) {
                ret = [_fm createFolder:i.fullPath];
                i.path = ret;
            }else{
                ret = [_fm createFile:i.fullPath Content:[NSData data]];
                i.path = ret;
            }
            
            if (ret.length == 0) {
                showToast(ZHLS(@"DuplicateError"));
                return;
            }
            
            [selectParent addChild:i];
            selectParent.open = YES;
            
            dataArray = root.itemsCanReach.mutableCopy;
            [dataArray insertObject:root atIndex:0];
            [fileListView reloadData];
            
            if (i.type == FileTypeText) {
                _fm.currentItem = i;
                if (kDevicePhone) {
                    [self performSegueWithIdentifier:@"edit" sender:self];
                }
            }
        }
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void)deleteItems:(NSArray<Item*>*)items
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ZHLS(@"DeleteMessage") message:nil delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"Delete"), nil];
    alert.clickedButton = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {
            for (Item *i in items) {
                [i removeFromParent];
                [_fm deleteFile:i.fullPath];
            }
            [self reload];
        }
    };
    [alert show];
    
}

- (void)moveItems:(NSArray<Item*>*)items toParent:(Item*)parent
{
    NSInteger successCount = items.count;
    for (Item *i in items) {
        NSString *newPath = [parent.fullPath stringByAppendingPathComponent:i.name];
        if (i.extention.length) {
            newPath = [newPath stringByAppendingPathExtension:i.extention];
        }
        
        BOOL ret = [_fm moveFile:i.fullPath toNewPath:newPath];
        if (!ret) {
            successCount --;
//            showToast(ZHLS(@"DuplicateError"));
//            return;
        }
    }

    NSLog(@"success:%i;failed:%i",successCount,items.count - successCount);
    [_fm createLocalWorkspace];
    [_fm createCloudWorkspace];
    [self reload];
}

@end
