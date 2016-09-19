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

@interface FileListViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIViewControllerPreviewingDelegate,UISearchBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *localListView;
@property (weak, nonatomic) IBOutlet UITableView *cloudListView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic) BOOL cloud;

@end

@implementation FileListViewController
{
    Item *root;
    FileManager *fm;
    Item *selectParent;
    Item *selectItem;
    BOOL edit;

    NSMutableArray *dataArray;
    UIBarButtonItem *rightItem;
    UIBarButtonItem *leftItem;
    UIPopoverPresentationController *popVc;
    UITableView *fileListView;
    UISegmentedControl *segment;
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    fm = [FileManager sharedManager];
    
    self.cloud = NO;
    [self.localListView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:@"file"];
    [self.cloudListView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:@"file"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"ItemsChangedNotification" object:nil];
    self.searchBar.placeholder = ZHLS(@"Search");
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title = ZHLS(self.cloud?@"NavTitleCloudFile":@"NavTitleLocalFile");
    [self reload];
}

- (void)toggleCloud
{
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
    _cloud ? [fm createCloudWorkspace] : [fm createLocalWorkspace];

    root = _cloud ? fm.cloud : fm.local;
    dataArray = root.itemsCanReach.mutableCopy;
    if (edit) {
        [dataArray insertObject:root atIndex:0];
    }
    fileListView = _cloud ? _cloudListView : _localListView;
    [fileListView reloadData];
}


- (NSArray*)rightItems
{
    rightItem = [[UIBarButtonItem alloc]initWithTitle:ZHLS(edit ? @"Done":@"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    return @[rightItem];
}

- (NSArray*)leftItems
{
    leftItem = [[UIBarButtonItem alloc]initWithTitle:ZHLS(self.cloud?@"NavTitleLocalFile":@"NavTitleCloudFile") style:UIBarButtonItemStylePlain target:self action:@selector(toggleCloud)];
    return @[leftItem];
}

- (void)edit
{
    edit = !edit;

    if (edit) {
        rightItem.title = ZHLS(@"Done");
        [dataArray insertObject:root atIndex:0];
    }else{
        rightItem.title = ZHLS(@"Edit");
        [dataArray removeObjectAtIndex:0];
    }
    [fileListView reloadData];
}


#pragma mark 功能逻辑

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

- (void)renameItem:(Item*)i
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"Rename") message:ZHLS(@"NameAlertMessage") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
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
            
            if ([fm moveFile:oldFullPath toNewPath:newFullPath]) {
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
                ret = [fm createFolder:i.fullPath];
                i.path = ret;
            }else{
                ret = [fm createFile:i.fullPath Content:[NSData data]];
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
                fm.currentItem = i;
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

- (void)searchWithWord:(NSString*)word
{
    if (word.length == 0) {
        dataArray = root.itemsCanReach.mutableCopy;
    }else {
        dataArray = [root searchResult:word].mutableCopy;
    }
    [fileListView reloadData];
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
    
    Item *item = dataArray[indexPath.row];
    
    cell.shift = edit ? 1 : 0;
    cell.edit = edit;
    cell.item = item;
    
    __weak UITableViewCell *__cell = cell;
    
    cell.moreBlock = ^(Item *i){
        if (kDevicePad) {
            UIAlertView *sheet = [[UIAlertView alloc]initWithTitle:i.name message:nil delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"Move"),ZHLS(@"Rename"),ZHLS(@"Export"), nil];
            if (i.type == FileTypeFolder) {
                sheet = [[UIAlertView alloc]initWithTitle:i.name message:nil delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"Move"),ZHLS(@"Rename"), nil];
            }
            __weak UIAlertView *__sheet = sheet;

            sheet.clickedButton = ^(NSInteger buttonIndex){
                if ([[__sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Move")]) {
                    selectItem = i;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"move" sender:self];
                    });
                }else if([[__sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Rename")]){
                    [self renameItem:i];
                }else if([[__sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Export")]){
                    [self export:i sourceView:__cell];
                }
            };
            [sheet show];
            return ;
        }
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:i.name delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: ZHLS(@"Move"),ZHLS(@"Rename"),ZHLS(@"Export"), nil];
        if (i.type == FileTypeFolder) {
            sheet = [[UIActionSheet alloc]initWithTitle:i.name delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:ZHLS(@"Move"), ZHLS(@"Rename"), nil];
        }
        __weak UIActionSheet *__sheet = sheet;
        sheet.clickedButton = ^(NSInteger buttonIndex){
            if ([[__sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Move")]) {
                selectItem = i;
                [self performSegueWithIdentifier:@"move" sender:self];
            }else if([[__sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Rename")]){
                [self renameItem:i];
            }else if([[__sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Export")]){
                [self export:i sourceView:__cell];
            }
        };
        [sheet showInView:self.view];
    };

    cell.newFileBlock = ^(Item *i){
        [self addFileWithParent:item];
    };
    
    cell.deleteFileBlock = ^(Item *i){
        if (i == root) {
            showToast(ZHLS(@"CanNotDeleteRoot"));
            return ;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ZHLS(@"DeleteMessage") message:nil delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
        alert.clickedButton = ^(NSInteger buttonIndex){
            if (buttonIndex == 1) {
                [i removeFromParent];
                NSArray *children = [i itemsCanReach];

                NSMutableArray *indexPaths = [NSMutableArray array];
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:[dataArray indexOfObject:item] inSection:0];
                [indexPaths addObject:index];
                
                for (Item *child in children) {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:[dataArray indexOfObject:child] inSection:0];
                    [indexPaths addObject:index];
                }
                
                [dataArray removeObject:i];
                [dataArray removeObjectsInArray:children];
                
                [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
                [fm deleteFile:i.fullPath];
            }
        };
        [alert show];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([dataArray[indexPath.row] isKindOfClass:[NSDictionary class]]) {
        return;
    }
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
    
    if (kDevicePhone) {
        [self performSegueWithIdentifier:@"edit" sender:self];
    }
}


- (NSURL *)fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}

- (void)export:(Item *) i sourceView:(UIView*)view{
    NSURL *url = [NSURL fileURLWithPath:i.fullPath];
    NSArray *objectsToShare = @[url];
    
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
    if ([segue.identifier isEqualToString:@"move"]) {
        ChooseFolderViewController *vc = [(UINavigationController*)segue.destinationViewController viewControllers].firstObject;
        vc.didChoosedFolder = ^(Item *i){
            [self moveItem:selectItem toParent:i];
        };
    }
}

- (void)moveItem:(Item*)i toParent:(Item*)parent
{
    NSString *newPath = [parent.fullPath stringByAppendingPathComponent:i.name];
    if (i.extention.length) {
        newPath = [newPath stringByAppendingPathExtension:i.extention];
    }

    BOOL ret = [fm moveFile:i.fullPath toNewPath:newPath];
    if (!ret) {
        showToast(ZHLS(@"DuplicateError"));
        return;
    }

    [fm createLocalWorkspace];
    [fm createCloudWorkspace];
    [self reload];
}

@end
