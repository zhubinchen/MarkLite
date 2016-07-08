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
#import <StoreKit/StoreKit.h>

@interface FileListViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIViewControllerPreviewingDelegate,UISearchBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SKPaymentTransactionObserver,SKProductsRequestDelegate>

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

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

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
    NSString *tryTitle = ZHLS(@"Try");
    if ([tryTitle isEqualToString:@"试用1天"] && [[NSDate date] compare:[NSDate dateWithString:@"2016-07-8 12:00:00"]] == NSOrderedDescending) {
        tryTitle = @"好评后免费试用一天";
    }
    if ([Configure sharedConfigure].iCloudState == 1) {
        tryTitle = nil;
    }
    if (self.cloud == NO && [Configure sharedConfigure].iCloudState < 2) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"UnlockTitle") message:@"" delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"Unlock"), tryTitle,nil];
        alert.clickedButton = ^(NSInteger index,UIAlertView *alert){
            if (index == 1) {
                [self requestProductData:kProductCloud];
            }else if (index == 2){
                [Configure sharedConfigure].iCloudState = 2;
                if ([tryTitle isEqualToString:@"好评后免费试用一天"]) {
                    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
                }else{
                    showToast(ZHLS(@"TriedTips"));
                }
            }
        };
        [alert show];
        return;
    }
    [fm createCloudWorkspace];
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
    alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
        if (buttonIndex == 1) {
            NSString *name = [alert textFieldAtIndex:0].text;
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
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:ZHLS(@"ChooseYourOperation") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:ZHLS(@"NewMarkdownFile"),ZHLS(@"PickImage"),ZHLS(@"NewFolder"), nil];
    sheet.clickedButton = ^(NSInteger buttonIndex,UIActionSheet *sheet){
        if (buttonIndex == 1) {
            UIImagePickerController *vc = [[UIImagePickerController alloc]init];
            vc.delegate = self;
            vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:vc animated:YES completion:nil];
            return ;
        }else if (buttonIndex == 0 || buttonIndex == 2) {
            FileType type = buttonIndex == 0 ? FileTypeText : FileTypeFolder;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"NameAlertTitle") message:ZHLS(@"NameAlertMessage") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
                if (buttonIndex == 1) {
                    [[alert textFieldAtIndex:0] resignFirstResponder];
                    NSString *name = [alert textFieldAtIndex:0].text;
                    if (type == FileTypeText) {
                        name = [name stringByAppendingString:@".md"];
                    }
                    NSString *path = name;
                    if (!selectParent.root) {
                        path = [parent.path stringByAppendingPathComponent:name];
                    }
                    Item *i = [[Item alloc]init];
                    i.path = path;
                    i.open = YES;
                    i.cloud = selectParent.cloud;
                    
                    BOOL ret = NO;
                    if (i.type == FileTypeFolder) {
                        ret = [fm createFolder:i.fullPath];
                    }else{
                        ret = [fm createFile:i.fullPath Content:[NSData data]];
                    }
                    
                    if (ret == NO) {
                        showToast(ZHLS(@"DuplicateError"));
                        return;
                    }
                    
                    [parent addChild:i];
                    
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
            [alert show];
        }
    };
    
    [sheet showInView:self.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"NameAlertTitle") message:ZHLS(@"NameAlertMessage") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
        if (buttonIndex == 1) {
            [[alert textFieldAtIndex:0] resignFirstResponder];
            NSString *name = [alert textFieldAtIndex:0].text;
            name = [name stringByAppendingString:@".png"];
            
            NSString *path = name;
            if (selectParent != root) {
                path = [selectParent.path stringByAppendingPathComponent:name];
            }
            Item *i = [[Item alloc]init];
            i.path = path;
            i.open = YES;
            i.cloud = selectParent.cloud;
            UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(img, 0.5);
            BOOL ret = [[FileManager sharedManager] createFile:i.fullPath Content:data];
            
            if (ret == NO) {
                showToast(ZHLS(@"DuplicateError"));
                return;
            }
            [selectParent addChild:i];
            
            dataArray = root.itemsCanReach.mutableCopy;
            [dataArray insertObject:root atIndex:0];
            fm.currentItem = i;
            [fileListView reloadData];
            
            if (kDevicePhone) {
                [self performSegueWithIdentifier:@"preview" sender:self];
            }
        }
    };

    [picker dismissViewControllerAnimated:YES completion:^{
        [alert show];
    }];
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

        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:i.name delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: ZHLS(@"Move"),ZHLS(@"Rename"),ZHLS(@"Export"), nil];
        if (i.type == FileTypeFolder) {
            sheet = [[UIActionSheet alloc]initWithTitle:i.name delegate:nil cancelButtonTitle:ZHLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:ZHLS(@"Move"), ZHLS(@"Rename"), nil];
        }
        sheet.clickedButton = ^(NSInteger buttonIndex,UIActionSheet *sheet){
            if ([[sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Move")]) {
                selectItem = i;
                [self performSegueWithIdentifier:@"move" sender:self];
            }else if([[sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Rename")]){
                [self renameItem:i];
            }else if([[sheet buttonTitleAtIndex:buttonIndex] isEqualToString:ZHLS(@"Export")]){
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
        alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
            if (buttonIndex == 1) {
                [i removeFromParent];
                NSArray *children = [i itemsCanReach];
                [dataArray removeObject:dataArray[indexPath.row]];
                [dataArray removeObjectsInArray:children];
                [dataArray removeObject:i];
                NSMutableArray *indexPaths = [NSMutableArray array];
                for (int i = 0; i < children.count + 1; i++) {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row+i inSection:0];
                    [indexPaths addObject:index];
                }
                
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
        if (i.type == FileTypeImage) {
            [self performSegueWithIdentifier:@"preview" sender:self];
        }else {
            [self performSegueWithIdentifier:@"edit" sender:self];
        }
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

#pragma mark purchase
//请求商品
- (void)requestProductData:(NSString *)type{
    if (![SKPaymentQueue canMakePayments]){
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:ZHLS(@"Alert")
                                                            message:ZHLS(@"DoesNotSupportPurchase")
                                                           delegate:nil
                                                  cancelButtonTitle:ZHLS(@"Close")
                                                  otherButtonTitles:nil];
        
        [alerView show];
        return;
    }
    
    NSLog(@"-------------请求对应的产品信息----------------");
    beginLoadingAnimationOnParent(ZHLS(@"Loading"), self.view);
    NSArray *product = [[NSArray alloc] initWithObjects:type, nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        NSLog(@"--------------没有商品------------------");
        stopLoadingAnimation();
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%ld",(unsigned long)[product count]);
    
    SKProduct *p = product.firstObject;
    NSLog(@"%@", [p description]);
    NSLog(@"%@", [p localizedTitle]);
    NSLog(@"%@", [p localizedDescription]);
    NSLog(@"%@", [p price]);
    NSLog(@"%@", [p productIdentifier]);
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    stopLoadingAnimation();
    
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:ZHLS(@"Alert")
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:ZHLS(@"Close")
                                              otherButtonTitles:nil];
    [alerView show];
}

- (void)requestDidFinish:(SKRequest *)request{
    
    NSLog(@"------------反馈信息结束-----------------");
}


//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){
        NSLog(@"%@",tran.payment.productIdentifier);
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                [Configure sharedConfigure].iCloudState = 3;
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                [self completeTransaction:tran];
                break;
            default:
                break;
        }
    }
    stopLoadingAnimation();
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    if ([transaction.payment.productIdentifier isEqualToString:kProductCloud]) {
        [Configure sharedConfigure].iCloudState = 3;
        showToast(ZHLS(@"UnlockedTips"));
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
