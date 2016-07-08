//
//  ChooseFolderViewController.m
//  MarkLite
//
//  Created by zhubch on 7/5/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "ChooseFolderViewController.h"
#import "FileItemCell.h"
#import "FileManager.h"
#import <StoreKit/StoreKit.h>
#import "Configure.h"

@interface ChooseFolderViewController ()<UITableViewDelegate,UITableViewDataSource,SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (weak, nonatomic) IBOutlet UITableView *folderListView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;

@end

@implementation ChooseFolderViewController
{
    NSMutableArray *dataArray;
    Item *selectedFolder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.folderListView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"file"];
    [self.segment setTitle:ZHLS(@"NavTitleLocalFile") forSegmentAtIndex:0];
    [self.segment setTitle:ZHLS(@"NavTitleCloudFile") forSegmentAtIndex:1];
    self.navigationItem.leftBarButtonItem.title = ZHLS(@"Cancel");
    self.navigationItem.rightBarButtonItem.title = ZHLS(@"Next");
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self loadFolder:NO];
}

- (void)loadFolder:(BOOL)icloud
{
    NSString *tryTitle = ZHLS(@"Try");
    if ([tryTitle isEqualToString:@"试用1天"] && [[NSDate date] compare:[NSDate dateWithString:@"2016-07-8 12:00:00"]] == NSOrderedDescending) {
        tryTitle = @"好评后免费试用一天";
    }
    if ([Configure sharedConfigure].iCloudState == 1) {
        tryTitle = nil;
    }
    if (icloud && [Configure sharedConfigure].iCloudState < 2) {
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
        [self.segment setSelectedSegmentIndex:0];
        return;
    }
    Item *root = icloud ? [FileManager sharedManager].cloud : [FileManager sharedManager].local;
    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeFolder) {
            return YES;
        }
        return NO;
    }];
    dataArray = [root.items filteredArrayUsingPredicate:pre].mutableCopy;
    [dataArray insertObject:root atIndex:0];
    [self.folderListView reloadData];
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
    cell.shift = 1;
    cell.item = item;
    cell.moreBtn.hidden = YES;
    cell.checkIcon.hidden = selectedFolder != item;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedFolder = dataArray[indexPath.row];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.didChoosedFolder(selectedFolder);
    }];
}

- (IBAction)segmentChanged:(UISegmentedControl*)sender
{
    [self loadFolder:sender.selectedSegmentIndex == 1];
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
    beginLoadingAnimation(ZHLS(@"Loading"));
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
