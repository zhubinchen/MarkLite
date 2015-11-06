//
//  AppDelegate.m
//  MarkLite
//
//  Created by zhubch on 11/3/15.
//  Copyright (c) 2015 zhubch. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)createItem
{
    //自定义icon 的初始化方法
    //    UIApplicationShortcutIcon *icon1 = [UIApplicationShortcutIcon iconWithTemplateImageName:@"your_icon"];
    //    UIMutableApplicationShortcutItem *item0 = [[UIMutableApplicationShortcutItem alloc] initWithType:@"com.your.helloWorld" localizedTitle:@"Title" localizedSubtitle:@"sub Title" icon:icon1 userInfo:nil];
    //这种是随意没有icon 的
    UIMutableApplicationShortcutItem *item1 = [[UIMutableApplicationShortcutItem alloc] initWithType:@"test.com.A" localizedTitle:@"三条A"];
    UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc] initWithType:@"test.com.B" localizedTitle:@"三条B"];
    UIMutableApplicationShortcutItem *item3 = [[UIMutableApplicationShortcutItem alloc] initWithType:@"test.com.C" localizedTitle:@"三条C"];
    
    NSArray *addArr = @[item2,item3,item1];
    //为什么这两句话可以不用，因为我们可以在plist 里面 加入 UIApplicationShortcutItems
    //    NSArray *existArr = [UIApplication sharedApplication].shortcutItems;
    //    [UIApplication sharedApplication].shortcutItems = [existArr arrayByAddingObjectsFromArray:addArr];
    [UIApplication sharedApplication].shortcutItems = addArr;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self createItem];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
