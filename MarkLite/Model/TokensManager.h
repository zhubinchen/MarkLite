//
//  TokensManager.h
//  MarkLite
//
//  Created by zhubch on 15-3-30.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TokensManager : NSObject

@property (nonatomic,strong) NSMutableArray *tokens;

+ (instancetype)sharedManager;

@end
