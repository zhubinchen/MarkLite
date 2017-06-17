//
//  MenuViewController.m
//  MarkLite
//
//  Created by Bingcheng on 15-3-27.
//  Copyright (c) 2016年 Bingcheng. All rights reserved.
//

#import "MenuViewController.h"
#import "Configure.h"
#import "ImageViewController.h"
#import "SeparatorLine.h"
#import <StoreKit/StoreKit.h>
#import "FontViewController.h"

@interface MenuViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property(nonatomic,weak) IBOutlet UITableView *tableView;
@end

@implementation MenuViewController
{
    NSArray *items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    items = @[@"",@"AssistKeyboard",@"UseLocalImage",@"Font",@"RateIt",@"Feedback",@"Donate"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchKeyboard:(UISwitch*)s{
    [Configure sharedConfigure].keyboardAssist = s.on;
}

- (void)switchLocalImage:(UISwitch*)s{
    [Configure sharedConfigure].useLocalImage = s.on;

    if (s.on) {
        EXUAlertView *alert = [[EXUAlertView alloc]initWithTitle:ZHLS(@"LocalImageTips") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"OK"), nil];
        alert.clickedButton = ^(NSInteger index){
            if (index == 0) {
                s.on = NO;
                [Configure sharedConfigure].useLocalImage = NO;
            }
        };
        [alert show];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    NSString *title = items[indexPath.row];
    
    
    if ([title isEqualToString:@"AssistKeyboard"]) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
        UISwitch *s = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 7, 0, 0)];
        s.tintColor = kPrimaryColor;
        s.onTintColor = kPrimaryColor;
        s.on = [Configure sharedConfigure].keyboardAssist;
        [s addTarget:self action:@selector(switchKeyboard:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:s];
    }else if ([title isEqualToString:@"UseLocalImage"]) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
        UISwitch *s = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 7, 0, 0)];
        s.tintColor = kPrimaryColor;
        s.onTintColor = kPrimaryColor;
        s.on = [Configure sharedConfigure].useLocalImage;
        [s addTarget:self action:@selector(switchLocalImage:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:s];
    } else{
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    }

    cell.textLabel.text = ZHLS(title);
    cell.textLabel.textColor = kPrimaryColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SeparatorLine *line = [[SeparatorLine alloc]initWithStart:CGPointMake(16, 49) width:self.view.bounds.size.width - 21 color:kPrimaryColor];
    [cell addSubview:line];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = @{@"ImageResolution":@"resolution",
                          @"AssistKeyboard":@"",
                          @"UseLocalImage":@"",
                          @"Font":@"font",
                          @"RateIt":@"rate",
                          @"Feedback":@"feedback",
                          @"Donate":@"donate"};
    NSString *key = items[indexPath.row];
    
    if ([dic[key] length] > 0) {
        SEL selector = NSSelectorFromString(dic[key]);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, selector);
    }
}
    
- (void)donate
{
    EXUAlertView *alert = [[EXUAlertView alloc]initWithTitle:ZHLS(@"DonateTitle") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"DonatePrice"), nil];
    alert.clickedButton = ^(NSInteger index){
        if (index) {
            [self requestProductData:kProductDonate];
        }
    };
    [alert show];
}

- (void)resolution
{
    UIViewController *vc = [[ImageViewController alloc]init];
    vc.title = ZHLS(@"ImageResolution");
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)font
{
    FontViewController *vc = [[FontViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rate
{
    [Configure sharedConfigure].hasRated = YES;
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
}

- (void)feedback
{
    NSString *url = @"mailto:cheng4741@gmail.com?subject=MarkLite%20Report&body=";
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

//请求商品
- (void)requestProductData:(NSString *)type{
    if (![SKPaymentQueue canMakePayments]){
        EXUAlertView *alerView =  [[EXUAlertView alloc] initWithTitle:ZHLS(@"DoesNotSupportPurchase")
                                                           delegate:nil
                                                  cancelButtonTitle:ZHLS(@"Close")
                                                  otherButtonTitles:nil];
        
        [alerView show];
        return;
    }
    
    NSLog(@"-------------请求对应的产品信息----------------");
    beginLoadingAnimation();
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
    
    EXUAlertView *alerView =  [[EXUAlertView alloc] initWithTitle:[error localizedDescription]
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
                [Configure sharedConfigure].hasRated = YES;
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                [self completeTransaction:tran];
                [self.tableView reloadData];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                showToast(ZHLS(@"Error"));
                [self completeTransaction:tran];
                break;
            default:
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    stopLoadingAnimation();
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


@end
