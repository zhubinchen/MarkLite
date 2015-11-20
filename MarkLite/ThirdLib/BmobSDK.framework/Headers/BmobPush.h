//
//  BmobPush.h
//  BmobSDK
//
//  Created by Bmob on 14-4-26.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"
@class BmobQuery;

@interface BmobPush : NSObject

/**
 *  创建一个推送对象
 *
 *  @return 一个推送对象
 */
+(BmobPush*)push;

/**
 *  设置查询里的约束条件
 *
 *  @param query 一般是Installation表的查询
 */
-(void)setQuery:(BmobQuery*)query;

/**
 *  设置多个订阅频道
 *
 *  @param channel 多个订阅频道放在数组里面
 */
-(void)setChannels:(NSArray *)channels;

/**
 *  设置单个订阅频道
 *
 *  @param channels 订阅的频道
 */
-(void)setChannel:(NSString *)channel;

/**
 *  设置推送消息
 *
 *  @param message 推送消息的内容
 */
-(void)setMessage:(NSString *)message;

/**
 *  设置推送消息
 *
 *  @param data 推送消息的内容，data里要包含alert键及对应的推送消息内容
 */
-(void)setData:(NSDictionary *)data;

/**
 *  设置过期的绝对日期时间
 *
 *  @param date 过期的日期时间
 */
-(void)expireAtDate:(NSDate *)date;

/**
 *  设置多少秒后过期
 *
 *  @param timeInterval 多少秒过期，
 */
-(void)expireAfterTimeInterval:(NSTimeInterval)timeInterval;

/**
 *  设置推送时间
 *
 *  @param date 推送的时期时间
 */
-(void)pushDate:(NSDate *)date;

/**
 *  异步发送推送
 */
-(void)sendPushInBackground;

/**
 *  异步发送推送
 *
 *  @param block 返回是否成功及错误信息
 */
-(void)sendPushInBackgroundWithBlock:(BmobBooleanResultBlock)block;

/**
 *  异步发送推送
 *
 *  @param channel 订阅频道
 *  @param message 推送消息内容
 */
+(void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message;

/**
 *  异步发送推送
 *
 *  @param channel 订阅频道
 *  @param message 推送消息内容
 *  @param block   推送消息的结果，是否成功以及失败的错误信息
 */
+(void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message
                                       block:(BmobBooleanResultBlock)block;

/**
 *  异步发送推送
 *
 *  @param query   Installation表查询里的约束条件
 *  @param message 推送消息内容
 */
+(void)sendPushMessageToQueryInBackground:(BmobQuery *)query
                               withMessage:(NSString *)message;

/**
 *  异步发送推送
 *
 *  @param query   查询里的约束条件
 *  @param message 推送消息内容
 *  @param block   推送消息的结果，是否成功以及失败的错误信息
 */
+(void)sendPushMessageToQueryInBackground:(BmobQuery *)query
                               withMessage:(NSString *)message
                                     block:(BmobBooleanResultBlock)block;
/**
 *  异步发送推送
 *
 *  @param channel 订阅频道
 *  @param data    推送消息内容，data里要包含alert键及对应的推送消息内容
 */
+(void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data;
/**
 *  异步发送推送
 *
 *  @param channel 订阅频道
 *  @param data    推送消息内容，data里要包含alert键及对应的推送消息内容
 *  @param block   推送消息的结果，是否成功以及失败的错误信息
 */
+(void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
                                    block:(BmobBooleanResultBlock)block;

/**
 *  异步发送推送
 *
 *  @param query Installation表查询里的约束条件
 *  @param data  推送消息内容，data里要包含alert键及对应的推送消息内容
 */
+(void)sendPushDataToQueryInBackground:(BmobQuery *)query
                               withData:(NSDictionary *)data;

/**
 *  异步发送推送
 *
 *  @param query Installation表查询里的约束条件
 *  @param data  推送消息内容，data里要包含alert键及对应的推送消息内容
 *  @param block 推送消息的结果，是否成功以及失败的错误信息
 */
+(void)sendPushDataToQueryInBackground:(BmobQuery *)query
                               withData:(NSDictionary *)data
                                  block:(BmobBooleanResultBlock)block;

/**
 *  弹出消息推送
 *
 *  @param userInfo 推送消息内容
 */
+(void)handlePush:(NSDictionary *)userInfo;

@end
