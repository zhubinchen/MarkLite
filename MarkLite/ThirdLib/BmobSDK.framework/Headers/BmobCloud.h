//
//  BmobCloud.h
//  BmobSDK
//
//  Created by Bmob on 13-12-31.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"

@interface BmobCloud : NSObject


/**
 *  传入参数同步调用云函数
 *
 *  @param function   函数名
 *  @param parameters 传递给函数的参数
 *
 *  @return 云函数响应结果
 */
+(id)callFunction:(NSString *)function withParameters:(NSDictionary *)parameters;

/**
 *  异步调用云函数
 *
 *  @param function   函数名
 *  @param parameters 传递给函数的参数
 *  @param block      云函数响应结果跟信息
 */
+(void)callFunctionInBackground:(NSString *)function withParameters:(NSDictionary *)parameters block:(BmobIdResultBlock)block;

@end
