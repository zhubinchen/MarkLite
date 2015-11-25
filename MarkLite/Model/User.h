//
//  User.h
//  MarkLite
//
//  Created by zhubch on 11/25/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

@property (nonatomic,strong) NSString *account;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,assign) BOOL hasLogin;

+ (instancetype)currentUser;

- (BOOL)archive;

@end
