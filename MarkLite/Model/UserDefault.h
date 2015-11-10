//
//  UserDefault.h
//  MarkLite
//
//  Created by zhubch on 15/4/7.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefault : NSObject

@property (nonatomic,strong) NSMutableArray *fileHistory;

@property (nonatomic,assign,readonly) BOOL oldUser;

@property (nonatomic,strong,readonly) NSArray *projectHistory;

@property (nonatomic,strong) NSDictionary *httpConfig;

@property (nonatomic,strong) NSDictionary *ftpConfig;

- (void)addProject:(NSDictionary*)project;

- (void)deleteProject:(NSDictionary*)project;

+ (instancetype)sharedDefault;

@end
