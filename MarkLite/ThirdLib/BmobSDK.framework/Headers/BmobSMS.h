//
//  BmobSMS.h
//  BmobSDK
//
//  Created by limao on 15/6/15.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"

/**
 *  短信验证码相关接口
 */
@interface BmobSMS : NSObject


/**
 *  请求短信信息
 *
 *  @param number   电话号码
 *  @param content  短信内容
 *  @param sendTime 发送时间（可为空）
 *  @param block    返回结果，含smsId,可用于查询短信发送状态
 */
+ (void)requestSMSInbackgroundWithPhoneNumber:(NSString*)number
                                      Content:(NSString*)content
                                  andSendTime:(NSString*)sendTime
                                  resultBlock:(BmobIntegerResultBlock)block;


/**
 *  请求验证码
 *
 *  @param number      手机号
 *  @param templateStr 模板名
 *  @param block       请求回调
 */
+ (void)requestSMSCodeInBackgroundWithPhoneNumber:(NSString*)number
                                      andTemplate:(NSString*)templateStr
                                      resultBlock:(BmobIntegerResultBlock)block;

/**
 *  验证验证码
 *
 *  @param number 手机号
 *  @param code   验证码
 *  @param block  回调
 */
+ (void)verifySMSCodeInBackgroundWithPhoneNumber:(NSString*)number andSMSCode:(NSString*)code resultBlock:(BmobBooleanResultBlock)block;

/**
 *  查询短信状态
 *
 *  @param smsId 验证码
 *  @param block 回调
 */
+ (void)querySMSCodeStateInBackgroundWithSMSId:(unsigned)smsId resultBlock:(BmobQuerySMSCodeStateResultBlock)block;

@end
