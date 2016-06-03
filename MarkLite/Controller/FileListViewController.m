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
#import "FileOperationCell.h"
#import "FileItemCell.h"
#import "Configure.h"

@interface FileListViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIViewControllerPreviewingDelegate,UISearchBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *fileListView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FileListViewController
{
    Item *root;
    FileManager *fm;
    
    NSMutableArray *dataArray;
    UIBarButtonItem *rightItem;
    BOOL edit;
    Item *selectParent;
}

#pragma mark 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    fm = [FileManager sharedManager];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recievedNotification:) name:@"launchFormShortCutItem" object:nil];
    [_fileListView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:nil] forCellReuseIdentifier:@"file"];
}

- (void)viewWillAppear:(BOOL)animated
{
    root = fm.root;
    dataArray = root.itemsCanReach.mutableCopy;
    if (edit) {
        [dataArray insertObject:root atIndex:0];
    }
    [self.fileListView reloadData];
}

- (NSArray*)rightItems
{
    rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(edit)];
    return @[rightItem];
}

- (void)edit
{
    edit = !edit;
    if (edit) {
        [dataArray insertObject:root atIndex:0];
    }else{
        [dataArray removeObjectAtIndex:0];
    }
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
    selectParent = parent;
    
    int index = 0;
    for (Item *i in dataArray) {
        index ++;
        if (i == parent) {
            break;
        }
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"请选择要进行的操作" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新建文本",@"创建文件夹",@"选取图片或视频", nil];
    sheet.clickedButton = ^(NSInteger buttonIndex,UIActionSheet *sheet){
        if (buttonIndex == 2) {
            UIImagePickerController *vc = [[UIImagePickerController alloc]init];
            vc.delegate = self;
            vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:vc animated:YES completion:nil];
            return ;
        }else if (buttonIndex == 0 || buttonIndex == 1) {
            FileType type = buttonIndex == 0 ? FileTypeText : FileTypeFolder;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"新建文本" message:@"请输入文件名" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
                if (buttonIndex == 1) {
                    [[alert textFieldAtIndex:0] resignFirstResponder];
                    NSString *name = [alert textFieldAtIndex:0].text;
                    if (type == FileTypeText) {
                        name = [name stringByAppendingString:@".md"];
                    }
                    NSString *path = name;
                    if (selectParent != root) {
                        path = [parent.path stringByAppendingPathComponent:name];
                    }
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
                    [dataArray insertObject:root atIndex:0];
                    [self.fileListView reloadData];
                    
                    if (i.type == FileTypeText) {
                        fm.currentItem = i;
                        if (kDevicePhone) {
                            [self performSegueWithIdentifier:@"edit" sender:self];
                        }
                    }
                }
            };
            [alert show];
        }
    };
    
    [sheet showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"新建文本" message:@"请输入文件名" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
        if (buttonIndex == 1) {
            [[alert textFieldAtIndex:0] resignFirstResponder];
            NSString *name = [alert textFieldAtIndex:0].text;
            name = [name stringByAppendingString:@".jpeg"];
            
            NSString *path = name;
            if (selectParent != root) {
                path = [selectParent.path stringByAppendingPathComponent:name];
            }
            Item *i = [[Item alloc]init];
            i.path = path;
            i.open = YES;
            UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(img, 0.5);
            [fm createFile:path Content:data];
            
            [selectParent addChild:i];
            
            dataArray = root.itemsCanReach.mutableCopy;
            [dataArray insertObject:root atIndex:0];
            fm.currentItem = i;
            [self.fileListView reloadData];
            
            if (kDevicePhone) {
                [self performSegueWithIdentifier:@"preview" sender:self];
            }
        }
    };

    [picker dismissViewControllerAnimated:YES completion:^{
        [alert show];
    }];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([dataArray[indexPath.row] isKindOfClass:[NSDictionary class]]) {
        FileOperationCell *cell = [[FileOperationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        cell.item = dataArray[indexPath.row][@"file"];
        cell.width = self.view.bounds.size.width;
        cell.deleteFileBlock = ^(Item *i){
            if (i == root) {
                showToast(@"根目录不可删除");
                return ;
            }
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"删除后不可恢复，确定要删除吗？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
            sheet.clickedButton = ^(NSInteger buttonIndex,UIActionSheet *alert){
                if (buttonIndex == 0) {
                    [i removeFromParent];
                    NSArray *children = [i itemsCanReach];
                    [dataArray removeObject:dataArray[indexPath.row]];
                    [dataArray removeObjectsInArray:children];
                    [dataArray removeObject:i];
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    for (int i = 0; i < children.count + 2; i++) {
                        NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row+i-1 inSection:0];
                        [indexPaths addObject:index];
                    }
                    
                    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
                    [fm deleteFile:i.path];
                }
            };
            [sheet showInView:self.view];
        };
        cell.renameFileBlock = ^(Item *i){
            if (i == root) {
                showToast(@"根目录不可重命名");
                return ;
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"重命名" message:@"不用输入后缀名" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
                NSString *name = [alert textFieldAtIndex:0].text;
                name = [name componentsSeparatedByString:@"."].firstObject;
                if (name.length == 0) {
                    showToast(@"文件名不可为空");
                    return ;
                }
                if ([name containsString:@"/"] || [name containsString:@"*"]) {
                    showToast(@"请不要输入特殊字符");
                    return;
                }
            };
            [alert show];
        };
        cell.exportBlock = ^(Item *i){
            [self export:i];
        };
        return cell;
    }
    
    FileItemCell *cell = (FileItemCell*)[tableView dequeueReusableCellWithIdentifier:@"file" forIndexPath:indexPath];
    
    Item *item = dataArray[indexPath.row];
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable && item.type != FileTypeFolder)
    {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    cell.shift = edit ? 1 : 0;
    cell.edit = edit;
    cell.item = item;
    
    cell.moreBlock = ^(Item *i){
        
        NSUInteger nextIndex = [dataArray indexOfObject:i] + 1;
        
        if (dataArray.count > nextIndex && [dataArray[nextIndex] isKindOfClass:[NSDictionary class]]) {
            [dataArray removeObjectAtIndex:(nextIndex)];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
            return ;
        }
        [dataArray insertObject:@{@"file":i} atIndex:nextIndex];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:nextIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationMiddle];
    };

    cell.newFileBlock = ^(Item *i){
        [self addFileWithParent:item];
    };

    cell.deleteFileBlock = ^(Item *i){
        if (i == root) {
            showToast(@"根目录不可删除");
            return ;
        }
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"删除后不可恢复，确定要删除吗？" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
        sheet.clickedButton = ^(NSInteger buttonIndex,UIActionSheet *alert){
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
        };
        [sheet showInView:self.view];
    };
    return cell;
}

- (NSURL *) fileToURL:(NSString*)filename
{
    NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];
    
    return [NSURL fileURLWithPath:filePath];
}

- (void)export:(Item *) i{
    NSURL *url = [NSURL fileURLWithPath:[fm fullPathForPath:i.path]];
    NSArray *objectsToShare = @[url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:controller animated:YES completion:nil];
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
        if (i.type == FileTypeImage) {
            [self performSegueWithIdentifier:@"preview" sender:self];
        }else {
            [self performSegueWithIdentifier:@"edit" sender:self];
        }
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
    EditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"edit"];
    vc.projectVc = self;
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}


@end
