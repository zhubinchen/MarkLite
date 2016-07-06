//
//  DonateViewController.m
//  MarkLite
//
//  Created by zhubch on 7/4/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "DonateViewController.h"
#import <StoreKit/StoreKit.h>

#define  kProductDonate1 @"com.zhubch.MarkLite.donate1"
#define  kProductDonate2 @"com.zhubch.MarkLite.donate2"
#define  kProductDonate3 @"com.zhubch.MarkLite.donate3"

@interface DonateViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation DonateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _activityView.hidden = YES;
    [_activityView stopAnimating];
}

- (IBAction)donate:(UIButton*)sender
{
    if (_activityView.hidden == NO) {
        return;
    }
    _activityView.hidden = NO;
    [_activityView startAnimating];
    NSArray *types = @[kProductDonate1,kProductDonate2,kProductDonate3];
    [self requestProductData:types[sender.tag]];
}

//请求商品
- (void)requestProductData:(NSString *)type{
    NSLog(@"-------------请求对应的产品信息----------------");
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
        _activityView.hidden = YES;
        [_activityView stopAnimating];
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
    NSLog(@"------------------错误-----------------:%@", error);
    _activityView.hidden = YES;
    [_activityView stopAnimating];
}

- (void)requestDidFinish:(SKRequest *)request{
    _activityView.hidden = YES;
    [_activityView stopAnimating];
    NSLog(@"------------反馈信息结束-----------------");
}


//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                
                break;
            default:
                break;
        }
    }
    _activityView.hidden = YES;
    [_activityView stopAnimating];
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    _activityView.hidden = YES;
    [_activityView stopAnimating];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
