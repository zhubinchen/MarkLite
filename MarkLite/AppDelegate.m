//
//  AppDelegate.m
//  MarkLite
//
//  Created by zhubch on 11/3/15.
//  Copyright (c) 2015 zhubch. All rights reserved.
//

#import "AppDelegate.h"
#import "Configure.h"
#import "FileManager.h"
#import "TabBarController.h"
#import "PathUtils.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)gotoStartPage
{
    [[TabBarController currentViewContoller].navigationController popToRootViewControllerAnimated:YES];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UITabBar appearance] setTintColor:kTintColor];
    [[UINavigationBar appearance] setTintColor:kTitleColor];
    [[UINavigationBar appearance] setBarTintColor:kNavBarColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                           NSForegroundColorAttributeName:kTitleColor
                                                           }];
    [self checkAppStoreVersion:@"1098107145"];

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

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *path = url.path;
    NSString *name = [path componentsSeparatedByString:@"/"].lastObject;
    NSData *content = [NSData dataWithContentsOfURL:url];
    FileManager *fm = [FileManager sharedManager];
    
    NSString *parentPath = [localWorkspace() stringByAppendingPathComponent:ZHLS(@"Recieved")];
    [fm createFolder:parentPath];
    
    Item *i = [[Item alloc]init];
    i.path = [ZHLS(@"Recieved") stringByAppendingPathComponent:name];
    i.cloud = NO;
    
    BOOL ret = [fm createFile:i.fullPath Content:content];
    if (!ret) {
        showToast(ZHLS(@"Error"));
        return YES;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:ZHLS(@"ReceivedNewFile"),name] message:@"" delegate:nil cancelButtonTitle:ZHLS(@"Ignore") otherButtonTitles:ZHLS(@"Open"), nil];
    alert.clickedButton = ^(NSInteger buttonIndex){
        if (buttonIndex == 1) {

            fm.currentItem = i;
            if (kDevicePhone) {
                [self gotoStartPage];

                [[TabBarController currentViewContoller].selectedViewController performSegueWithIdentifier:@"edit" sender:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ItemsChangedNotification" object:nil];
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
            UIAlertView *alert;
            alert = [[UIAlertView alloc] initWithTitle:ZHLS(@"UpgradeTitle")
                                               message:ZHLS(@"UpgradeTips")
                                              delegate: self
                                     cancelButtonTitle:ZHLS(@"Dont Upgrade")
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


@end
