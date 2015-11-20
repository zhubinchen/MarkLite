//
//  BmobMessage.h
//  BmobSDK
//
//  Created by limao on 15/5/29.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"

/**
 *  短信验证码相关接口
 */
@interface BmobMessage : NSObject

/**
 *  请求验证码，已遗弃，请使用[BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:number andTemplate:templateStr resultBlock:block]
 *
 *  @param number      手机号
 *  @param templateStr 模板名
 *  @param block       请求回调
 */
+ (void)requestSMSCodeInBackgroundWithPhoneNumber:(NSString*)number
                                      andTemplate:(NSString*)templateStr
                                      resultBlock:(BmobIntegerResultBlock)block
__deprecated_msg("Replace by `[BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:number andTemplate:templateStr resultBlock:block]`");

/**
 *  验证验证码，已遗弃，请使用[BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:number andSMSCode:code resultBlock:block]
 *
 *  @param number 手机号
 *  @param code   验证码
 *  @param block  回调
 */
+ (void)verifySMSCodeInBackgroundWithPhoneNumber:(NSString*)number
                                      andSMSCode:(NSString*)code
                                     resultBlock:(BmobBooleanResultBlock)block
__deprecated_msg("Replace by `[BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:number andSMSCode:code resultBlock:block]`");

/**
 *  查询短信状态，已遗弃，请使用[BmobSMS querySMSCodeStateInBackgroundWithSMSId:smsId resultBlock:block]
 *
 *  @param smsId 验证码
 *  @param block 回调
 */
+ (void)querySMSCodeStateInBackgroundWithSMSId:(unsigned)smsId
                                   resultBlock:(BmobQuerySMSCodeStateResultBlock)block
__deprecated_msg("Replace by `[BmobSMS querySMSCodeStateInBackgroundWithSMSId:smsId resultBlock:block]`");

@end
