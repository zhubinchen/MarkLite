//
//  ImageViewController.m
//  MarkLite
//
//  Created by zhubch on 6/27/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "ImageViewController.h"
#import "Configure.h"
#import <StoreKit/StoreKit.h>

#define  kProductThreeMonthID @"com.zhubch.MarkLite.threeMonth"
#define  kProductSixMonthID @"com.zhubch.MarkLite.sixMonth"
#define  kProductForeverID @"com.zhubch.MarkLite.forever"

@interface ImageViewController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (nonatomic,weak) IBOutlet UIButton *purchaseBtn;
@property (nonatomic,weak) IBOutlet UISlider *slider;
@property (nonatomic,weak) IBOutlet UIView *view1;
@property (nonatomic,weak) IBOutlet UIView *view2;
@property (nonatomic,weak) IBOutlet UIView *view3;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"图床服务";
    self.slider.value = [Configure sharedConfigure].compressionQuality;
}

- (void)viewDidLayoutSubviews
{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view1 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view3 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view1 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 89.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view3 addSubview:line];
}

- (IBAction)purchaseFunc:(id)sender {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    if (![SKPaymentQueue canMakePayments]) {
        showToast(@"您的设备不允许购买");
        return;
    }
    
    if (![Configure sharedConfigure].hasStared) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请选择要购买的套餐" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"好评试用一星期",@"3个月(¥6)",@"6个月(¥12)",@"永久(¥18)", nil];
        alert.clickedButton = ^(NSInteger index,UIAlertView *alert){
            if (index == 1){
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1098107145&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
            }
            if (index > 1) {
                NSArray *types = @[kProductThreeMonthID,kProductSixMonthID,kProductForeverID];
                [self requestProductData:types[index - 2]];
            }
            
        };
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请选择要购买的套餐" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"3个月(¥6)",@"6个月(¥12)",@"永久(¥18)", nil];
        alert.clickedButton = ^(NSInteger index,UIAlertView *alert){

            if (index > 0) {
                NSArray *types = @[kProductThreeMonthID,kProductSixMonthID,kProductForeverID];
                [self requestProductData:types[index - 1]];
            }
            
        };
        [alert show];
    }
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


- (IBAction)compressionQualityChanged:(UISlider*)sender{
    [Configure sharedConfigure].compressionQuality = sender.value;
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
