//
//  UserDefault.m
//  MarkLite
//
//  Created by zhubch on 15/4/7.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "UserDefault.h"

@implementation UserDefault
{
    NSUserDefaults *ud;
    NSMutableArray *projectArray;
}

@synthesize httpConfig = _httpConfig;

+ (instancetype)sharedDefault
{
    static UserDefault *userDefault = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        userDefault = [[UserDefault alloc]init];
    });
    
    return userDefault;
}

- (instancetype)init
{
    if (self = [super init]) {
        ud = [NSUserDefaults standardUserDefaults];
        
        _oldUser = [ud boolForKey:@"oldUser"];
        if (!_oldUser) {
            [ud setBool:YES forKey:@"oldUser"];
        }
        
        projectArray = [[ud objectForKey:@"projectHistory"] mutableCopy];
        if (projectArray == nil) {
            projectArray = [NSMutableArray array];
        }
        
        _httpConfig = [ud objectForKey:@"httpConfig"];
    }
    
    return self;
}

- (void)addProject:(NSDictionary *)project
{
    [projectArray addObject:project];
    
    [[NSUserDefaults standardUserDefaults]setObject:projectArray forKey:@"projectHistory"];
}

- (void)deleteProject:(NSDictionary *)project
{
    [projectArray removeObject:project];
    [[NSUserDefaults standardUserDefaults]setObject:projectArray forKey:@"projectHistory"];
}

- (NSArray *)projectHistory
{
    return projectArray;
}

- (void)setHttpConfig:(NSDictionary *)httpConfig
{
    _httpConfig = httpConfig;
    [ud setObject:httpConfig forKey:@"httpConfig"];
}

- (void)setFtpConfig:(NSDictionary *)ftpConfig
{
    _ftpConfig = ftpConfig;
    [ud setObject:ftpConfig forKey:@"ftpConfig"];
}

@end
