//
//  Bmob.h
//  BmobSDK
//
//  Created by Bmob on 13-7-31.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//包含头文件
#import "BmobObject.h"
#import "BmobFile.h"
#import "BmobGeoPoint.h"
#import "BmobQuery.h"
#import "BmobUser.h"
#import "BmobCloud.h"
#import "BmobConfig.h"
#import "BmobRelation.h"
#import "BmobObjectsBatch.h"
#import "BmobPush.h"
#import "BmobInstallation.h"
#import "BmobACL.h"
#import "BmobRole.h"
#import "BmobImage.h"
#import "BmobEvent.h"
#import "BQLQueryResult.h"
#import "BmobObject+Subclass.h"
#import "BmobMessage.h"
#import "BmobSMS.h"
#import "BmobTableSchema.h"

/**
 *  初始化成功的通知，注册该通知可以在初始化成功后执行需要的动作，最新版本的初始化过程已经修改成同步，因此该通过可以不作处理
 */
extern NSString *const  kBmobInitSuccessNotification;

/**
 *  初始化失败的通知
 */
extern NSString *const  kBmobInitFailNotification;

@interface Bmob : NSObject


/**
 *	向Bmob注册应用
 *
 *	@param	appKey	在网站注册的appkey
 */
+(void)registerWithAppKey:(NSString*)appKey;


/**
 *  得到服务器时间戳
 *
 *  @return 时间戳字符串 (到秒)
 */
+(NSString*)getServerTimestamp;


/**
 *  在应用进入前台是调用
 */
+(void)activateSDK;

+(void)setBmobRequestTimeOut:(CGFloat)seconds;

# pragma mark - 获取表结构
+ (void)getAllTableSchemasWithCallBack:(BmobAllTableSchemasBlock)block;

+ (void)getTableSchemasWithClassName:(NSString*)tableName callBack:(BmobTableSchemasBlock)block;





@end
