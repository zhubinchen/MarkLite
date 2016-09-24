//
//  MenuViewController.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MenuViewController.h"
#import "Configure.h"
#import "AboutViewController.h"
#import "StyleViewController.h"
#import "ImageViewController.h"
#import <StoreKit/StoreKit.h>

@interface MenuViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@end

@implementation MenuViewController
{
    NSArray *items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:ZHLS(@"Back") style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    if (kDevicePad) {
        items = @[
                    @[@"ImageResolution"],
                    @[@"AssistKeyboard",@"Font"],
                    @[@"RateIt",@"Feedback"],
                    @[@"About"],@[@"Donate"]
                ];
    }else{
        items = @[
                    @[@"ImageResolution"],
                    @[@"AssistKeyboard",@"LandscapeEdit"],
                    @[@"RateIt",@"Feedback"],
                    @[@"About"],@[@"Donate"]
                  ];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title = ZHLS(@"NavTitleOptions");
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchKeyboard:(UISwitch*)s{
    [Configure sharedConfigure].keyboardAssist = s.on;
}

- (void)switchLandscape:(UISwitch*)s{
    [Configure sharedConfigure].landscapeEdit = s.on;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    NSString *title = items[indexPath.section][indexPath.row];


    if ([title isEqualToString:@"AssistKeyboard"]) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
        UISwitch *s = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 7, 0, 0)];
        s.on = [Configure sharedConfigure].keyboardAssist;
        [s addTarget:self action:@selector(switchKeyboard:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:s];
    }else if ([title isEqualToString:@"LandscapeEdit"]) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
        UISwitch *s = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 7, 0, 0)];
        s.on = [Configure sharedConfigure].landscapeEdit;
        [s addTarget:self action:@selector(switchLandscape:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:s];
    } else{
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = ZHLS(title);
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = @{@"ImageResolution":@"resolution",
                          @"AssistKeyboard":@"",
                          @"Font":@"font",
                          @"RateIt":@"rate",
                          @"Feedback":@"feedback",
                          @"About":@"about",
                          @"Donate":@"donate"};
    NSString *key = items[indexPath.section][indexPath.row];

    if ([dic[key] length] > 0) {
        SEL selector = NSSelectorFromString(dic[key]);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, selector);
    }
}

- (void)donate
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:ZHLS(@"DonateTitle") message:ZHLS(@"DonateTips") delegate:nil cancelButtonTitle:ZHLS(@"Cancel") otherButtonTitles:ZHLS(@"DonatePrice"), nil];
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
    [self performSegueWithIdentifier:@"font" sender:self];
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

- (void)about
{
    UIViewController *vc = [[AboutViewController alloc]init];
    vc.title = ZHLS(@"About");
    [self.navigationController pushViewController:vc animated:YES];
}

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
