//
//  BmobUser.h
//  BmobSDK
//
//  Created by Bmob on 13-8-6.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"
#import "BmobObject.h"

@class BmobQuery;

@interface BmobUser : BmobObject

#pragma mark 用户属性设置
/**
 *  用户名
 */
@property (copy, nonatomic) NSString *username;

/**
 *  密码
 */
@property (copy, nonatomic) NSString *password;

/**
 *  邮箱
 */
@property (copy, nonatomic) NSString *email;

/**
 *  手机号码
 */
@property (copy, nonatomic) NSString *mobilePhoneNumber;

#pragma mark 用户表查询
/**
 *  查询用户表
 *
 *  @return 创建用户表的查询
 */
+(BmobQuery *)query;

#pragma mark set
/**
 *	设置用户名
 *
 *	@param	username	提供的用户名
 */
-(void)setUserName:(NSString*)username __deprecated_msg("Replace by `self.username`");


#pragma mark 用户登录注册操作等相关操作
/**
 *  用户登陆
 *
 *  @param username 用户名
 *  @param password 密码
 */
+(void)loginWithUsernameInBackground:(NSString*)username
                            password:(NSString*)password;


/**
 *  登陆后返回用户信息
 *
 *  @param username 用户名
 *  @param password 密码
 *  @param block    是否成功登陆，若成功登陆返回用户信息
 */
+(void)loginWithUsernameInBackground:(NSString *)username
                             password:(NSString *)password
                                block:(BmobUserResultBlock)block;

/**
 *	注销登陆账号,删除本地账号
 */
+(void)logout;

/**
 *	后台注册
 */
-(void)signUpInBackground;


/**
 *	后台注册,返回注册结果
 *
 *	@param	block	返回成功还是失败
 */
-(void)signUpInBackgroundWithBlock:(BmobBooleanResultBlock)block;

/**
 *  邮件认证，在web端应用设置中又开启邮箱验证
 *
 *  @param email 邮箱地址
 */
-(void)verifyEmailInBackgroundWithEmailAddress:(NSString *)email;

/**
 *	通过邮件设置密码
 *
 *	@param	email	提供的邮件地址
 */
+(void)requestPasswordResetInBackgroundWithEmail:(NSString *)email;

/**
 *  得到邮箱验证的结果
 *
 *  @param block 邮箱验证的结果及其信息
 */
-(void)userEmailVerified:(BmobBooleanResultBlock)block;


/**
 *	得到当前BmobUser
 *
 *	@return	返回BmobUser对象
 */
+(BmobUser*)getCurrentObject __deprecated_msg("replace by `+(BmobUser*)getCurrentUser;`");

/**
 *	得到当前BmobUser
 *
 *	@return	返回BmobUser对象
 */
+(BmobUser*)getCurrentUser;

/**
 *  利用旧密码重置新密码
 *
 *  @param oldPassword 旧密码
 *  @param newPassword 新密码
 *  @param block       回调
 */
- (void)updateCurrentUserPasswordWithOldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword block:(BmobBooleanResultBlock)block;

#pragma mark - 第三方登录相关操作

/**
 *  第三方授权登录后，在Bmob生成一个bmob用户
 *
 *  @param infoDictionary  授权信息，格式为@{@"access_token":@"获取的token",@"uid":@"授权后获取的id",@"expirationDate":@"获取的过期时间（NSDate）"}
 *  @param platform        新浪微博，或者腾讯qq
 *  @param block           生成新的用户，跟结果信息
 */

+ (void)signUpInBackgroundWithAuthorDictionary:(NSDictionary *)infoDictionary
                                     platform:(BmobSNSPlatform)platform
                                        block:(BmobUserResultBlock)block;

/**
 *  第三方授权登录后，在Bmob生成一个bmob用户
 *
 *  @param infoDictionary  授权信息，格式为@{@"access_token":@"获取的token",@"uid":@"授权后获取的id",@"expirationDate":@"获取的过期时间（NSDate）"}
 *  @param platform        新浪微博，或者腾讯qq
 *  @param block           生成新的用户，跟结果信息
 */

+ (void)loginInBackgroundWithAuthorDictionary:(NSDictionary *)infoDictionary
                                      platform:(BmobSNSPlatform)platform
                                         block:(BmobUserResultBlock)block;
/**
 *  登录用户关联第三方账号
 *
 *  @param infoDictionary  授权信息，格式为@{@"access_token":@"获取的token",@"uid":@"授权后获取的id",@"expirationDate":@"获取的过期时间（NSDate）"}
 *  @param platform        新浪微博，或者腾讯qq
 *  @param block           关联结果跟信息
 */
-(void)linkedInBackgroundWithAuthorDictionary:(NSDictionary *)infoDictionary
                                     platform:(BmobSNSPlatform)platform
                                        block:(BmobBooleanResultBlock)block;


/**
 *  登录用户取消关联第三方账号
 *
 *  @param platform 新浪微博，或者腾讯qq
 *  @param block    取消关联结果跟信息
 */
-(void)cancelLinkedInBackgroundWithPlatform:(BmobSNSPlatform)platform
                                      block:(BmobBooleanResultBlock)block;


#pragma mark - 手机注册登录
/**
 *  手机号码加验证码一键注册登录
 *
 *  @param phoneNumber <#phoneNumber description#>
 *  @param smsCode     <#smsCode description#>
 */
+(void)signOrLoginInbackgroundWithMobilePhoneNumber:(NSString*)phoneNumber
                                         andSMSCode:(NSString*)smsCode
                                              block:(BmobUserResultBlock)block;

/**
 *  手机号码加验证码一键注册登录并且设置用户密码
 *
 *  @param phoneNumber 手机号
 *  @param smsCode     验证码
 *  @param password    用户密码
 *  @param block       回调
 */
+(void)signOrLoginInbackgroundWithMobilePhoneNumber:(NSString*)phoneNumber
                                             SMSCode:(NSString*)smsCode
                                         andPassword:(NSString *)password
                                               block:(BmobUserResultBlock)block;

/**
 *  手机号码加验证码一键注册登录，并且可设置用户表的其它信息
 *
 *  @param smsCode 验证码
 */
- (void)signUpOrLoginInbackgroundWithSMSCode:(NSString *)smsCode
                                       block:(BmobBooleanResultBlock)block;

/**
 *  账号密码登录，账号可以为用户名、手机号或者邮箱
 *
 *  @param account  <#account description#>
 *  @param password <#password description#>
 *  @param block    <#block description#>
 */
+(void)loginInbackgroundWithAccount:(NSString*)account
                        andPassword:(NSString*)password
                              block:(BmobUserResultBlock)block;

/**
 *  手机号码加验证码登录
 *
 *  @param phoneNumber <#phoneNumber description#>
 *  @param smsCode     <#smsCode description#>
 */
+(void)loginInbackgroundWithMobilePhoneNumber:(NSString*)phoneNumber
                                   andSMSCode:(NSString*)smsCode
                                        block:(BmobUserResultBlock)block;

/**
 *  利用短信验证码重置帐号密码，只有填写手机号码的用户可用
 *
 *  @param phoneNumber <#phoneNumber description#>
 *  @param smscode     <#smscode description#>
 *  @param block       <#block description#>
 */
+(void)resetPasswordInbackgroundWithSMSCode:(NSString*)SMSCode
                                              andNewPassword:(NSString*)newPassword
                                      block:(BmobBooleanResultBlock)block;


@end
