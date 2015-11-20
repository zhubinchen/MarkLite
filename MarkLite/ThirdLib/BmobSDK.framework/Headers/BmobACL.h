//
//  BmobACL.h
//  BmobSDK
//
//  Created by Bmob on 14-5-9.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BmobUser;
@class BmobRole;

@interface BmobACL : NSObject


/**
 *  创建BmobACL对象
 *
 *  @return BmobACL对象
 */
+(instancetype)ACL;

/**
 *  设置所有人读权限为true
 */
-(void)setPublicReadAccess;


/**
 *  设置所有人写权限为true
 */
-(void)setPublicWriteAccess;


/**
 *  设置某个用户读权限为true
 *
 *  @param userId 用户的objectId
 */
-(void)setReadAccessForUserId:(NSString *)userId;

/**
 *  设置某个用户写权限为true
 *
 *  @param userId 用户的objectId
 */
-(void)setWriteAccessForUserId:(NSString *)userId;

/**
 *  设置某个用户的读权限为true
 *
 *  @param user 某个BmobUser用户
 */
-(void)setReadAccessForUser:(BmobUser *)user;


/**
 *  设置某个用户的写权限为true
 *
 *  @param user BmobUser用户对象
 */
-(void)setWriteAccessForUser:(BmobUser *)user;

/**
 *  设置角色的读权限为true
 *
 *  @param name 角色名
 */
-(void)setReadAccessForRoleWithName:(NSString *)name;

/**
 *  设置角色的写权限为true
 *
 *  @param name 角色名
 */
-(void)setWriteAccessForRoleWithName:(NSString *)name;


/**
 *  设置角色的读权限为true
 *
 *  @param role BmobRole角色对象
 */
-(void)setReadAccessForRole:(BmobRole *)role;

/**
 *  设置角色的写权限为true
 *
 *  @param role BmobRole角色对象
 */
-(void)setWriteAccessForRole:(BmobRole *)role;



@end
