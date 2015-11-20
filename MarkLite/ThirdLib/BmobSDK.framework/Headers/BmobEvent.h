//
//  BmobEvent.h
//  BmobSDK
//
//  Created by Bmob on 14-7-4.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"

@protocol BmobEventDelegate ;

@interface BmobEvent : NSObject{
    
}

@property(assign)id<BmobEventDelegate>delegate;


-(instancetype)init;

/**
 *  单例模式创建BmobEvent对象
 *
 *  @return 创建BmobEvent对象
 */
+(instancetype)defaultBmobEvent;

/**
 *  启动
 */
-(void)start;

/**
 *  停止
 */
-(void)stop;

/**
 *  订阅表的变化事件
 *
 *  @param actionType 包括表更新，表删除
 *  @param tableName  表名
 */
-(void)listenTableChange:(BmobActionType)actionType tableName:(NSString *)tableName;

/**
 *  订阅行的变化事件
 *
 *  @param actionType 包含行更新，行删除
 *  @param tableName  表名
 *  @param objectId   行的objectId
 */
-(void)listenRowChange:(BmobActionType)actionType tableName:(NSString *)tableName objectId:(NSString *)objectId;

/**
 *  取消订阅表的变化事件
 *
 *  @param actionType 包括表更新，表删除
 *  @param tableName  表名
 */
-(void)cancelListenTableChange:(BmobActionType)actionType tableName:(NSString *)tableName;

/**
 *  取消订阅行的变化事件
 *
 *  @param actionType 包含行更新，行删除
 *  @param tableName  表名
 *  @param objectId   行的objectId
 */
-(void)cancelListenRowChange:(BmobActionType)actionType tableName:(NSString *)tableName objectId:(NSString *)objectId;

@end


@protocol BmobEventDelegate <NSObject>

@optional
/**
 *  连接上服务器
 *
 *  @param event BmobEvent对象
 */
-(void)bmobEventDidConnect:(BmobEvent *)event;

/**
 *  连接不了服务器
 *
 *  @param event BmobEvent对象
 *  @param error 错误信息
 */
-(void)bmobEventDidDisConnect:(BmobEvent *)event error:(NSError *)error;

/**
 *  可以订阅或者取消订阅
 *
 *  @param event BmobEvent对象
 */
-(void)bmobEventCanStartListen:(BmobEvent*)event;

/**
 *  BmobEvent发生错误时
 *
 *  @param event BmobEvent对象
 *  @param error 错误信息
 */
-(void)bmobEvent:(BmobEvent*)event error:(NSError *)error;

/**
 *  订阅事件时，接收信息
 *
 *  @param event   BmobEvent对象
 *  @param message 消息内容
 */
-(void)bmobEvent:(BmobEvent *)event didReceiveMessage:(NSString *)message;



@end