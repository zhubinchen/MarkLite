//
//  AppDelegate.m
//  MarkLite
//
//  Created by Bingcheng on 11/3/15.
//  Copyright (c) 2016 Bingcheng. All rights reserved.
//

#import "AppDelegate.h"
#import "Configure.h"
#import "PathUtils.h"
#import "Item.h"
#import "HomeViewController.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

static BOOL allowRotation = NO;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIImage *backImage = [UIImage imageNamed:@"nav_back"];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backImage.size.width, 0, 0)]                                                       forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-233, 0) forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setTintColor:kPrimaryColor];
    [[UINavigationBar appearance] setBarTintColor:kTitleColor];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName:fontOfSize(18),
                                                           NSForegroundColorAttributeName:kPrimaryColor
                                                           }];
    [self checkAppStoreVersion:@"1098107145"];
    [Configure sharedConfigure];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        NSString *tempPath = [documentPath() stringByAppendingPathComponent:@"temp"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
        for (NSString *path in paths) {
            NSError *err = nil;
            [[NSFileManager defaultManager] removeItemAtPath:[tempPath stringByAppendingPathComponent:path] error:&err];
            NSLog(@"%@",err);
        }
    });
    
    [Bugly startWithAppId:@"900059643"];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *path = url.path;
    NSString *name = [path componentsSeparatedByString:@"/"].lastObject;
    NSData *content = [NSData dataWithContentsOfURL:url];
    
    Item *local = [Item localRoot];
    
    Item *recieved = nil;
    
    for (Item *i in local.children) {
        if ([i.name isEqualToString:ZHLS(@"Recieved")]) {
            recieved = i;
            break;
        }
    }
    if (recieved == nil) {
        recieved = [local createItem:ZHLS(@"Recieved") type:FileTypeFolder];
    }
    Item *newItem = [recieved createItem:name type:FileTypeText];
    [newItem save:content];
    
    EXUAlertView *alert = [[EXUAlertView alloc]initWithTitle:[NSString stringWithFormat:ZHLS(@"ReceivedNewFile"),name] delegate:nil cancelButtonTitle:ZHLS(@"Ignore") otherButtonTitles:ZHLS(@"Open"), nil];
    alert.clickedButton = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {

            [Configure sharedConfigure].currentItem = newItem;
            if (kDevicePhone) {
                HomeViewController *vc = [(UINavigationController*)self.window.rootViewController viewControllers].firstObject;
                if (vc) {
                    vc.recievedItem = newItem;
                }
            }
        }
    };
    [alert show];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[Configure sharedConfigure] saveToFile];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ApplicationDidEnterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[Configure sharedConfigure] saveToFile];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"ApplicationWillTerminate" object:nil];
}

- (void)checkAppStoreVersion:(NSString *)appId
{
//#if defined(DEBUG)||defined(_DEBUG)
//    NSLog(@"调试模式不检查更新");
//    return;
//#endif
    //取得AppStroe信息
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appId]]];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval  = 2;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    //判断数据
    if(returnData != nil)
    {
        NSString *latestVersion = @"1.0";
        NSString *trackViewUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId];
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingAllowFragments error:nil];
        NSArray *resultArray = [dic objectForKey:@"results"];
        for (id config in resultArray)
        {
            latestVersion = [config valueForKey:@"version"];
            trackViewUrl = [config valueForKey:@"trackViewUrl"];
        }
        
        //比较版本
        double dblCurrentVersion = [kAppVersionNo doubleValue];
        double dblAppStoreVersion = [latestVersion doubleValue];
        if(dblCurrentVersion < dblAppStoreVersion)
        {
            //提示对话框
            EXUAlertView *alert;
            alert = [[EXUAlertView alloc] initWithTitle:ZHLS(@"UpgradeTips")
                                              delegate: nil
                                     cancelButtonTitle:ZHLS(@"DontUpgrade")
                                     otherButtonTitles:ZHLS(@"Upgrade"), nil];
            alert.clickedButton = ^(NSInteger buttonIndex){
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
                }
            };
            
            [alert show];
        }
    }
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (kDevicePad) {
        return UIInterfaceOrientationMaskAll;
    }
    if (allowRotation)
    {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    //只支持竖屏禁止全屏
    return UIInterfaceOrientationMaskPortrait;
}

+ (void)setAllowRotation:(BOOL)allow
{
    allowRotation = allow;
}

@end
