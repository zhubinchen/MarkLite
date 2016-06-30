//
//  DonateViewController.m
//  MarkLite
//
//  Created by zhubch on 6/30/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "DonateViewController.h"
#import <StoreKit/StoreKit.h>

#define  kProductDonate6ID @"com.zhubch.MarkLite.Donate6"
#define  kProductDonate12ID @"com.zhubch.MarkLite.Donate12"
#define  kProductDonate18ID @"com.zhubch.MarkLite.Donate18"

@interface DonateViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@end

@implementation DonateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)donate:(UIButton*)sender
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    if (![SKPaymentQueue canMakePayments]) {
        showToast(@"您的设备不允许购买");
        return;
    }
    
    NSArray *types = @[kProductDonate6ID,kProductDonate12ID,kProductDonate18ID];
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
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%ld",[product count]);
    
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
}

- (void)requestDidFinish:(SKRequest *)request{
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
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
