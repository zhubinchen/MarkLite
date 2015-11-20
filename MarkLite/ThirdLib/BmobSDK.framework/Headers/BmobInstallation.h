//
//  BmobInstallation.h
//  BmobSDK
//
//  Created by Bmob on 14-4-25.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobObject.h"
@class BmobQuery;



@interface BmobInstallation : BmobObject

/**
 *  Installation表查询
 *
 *  @return 查询Installation表的类
 */
+(BmobQuery *)query;

/**
 * BmobInstallation实例
 *
 *  @return BmobInstallation实例
 */
+(instancetype)currentInstallation;

/**
 *  绑定设备DeviceToken
 *
 *  @param deviceTokenData APNS返回的deviceToken
 */
- (void)setDeviceTokenFromData:(NSData *)deviceTokenData;


@property (nonatomic,copy   ) NSString *deviceType;
@property (nonatomic,copy   ) NSString *deviceToken;
@property (nonatomic,assign ) int      badge;
@property (nonatomic, strong) NSArray  *channels;

/**
 *  注册订阅频道
 *
 *  @param channels 订阅频道
 */
-(void)subsccribeToChannels:(NSArray*)channels;

/**
 *  取消订阅频道
 *
 *  @param channels 订阅频道数组
 */
-(void)unsubscribeFromChannels:(NSArray*)channels;
@end
