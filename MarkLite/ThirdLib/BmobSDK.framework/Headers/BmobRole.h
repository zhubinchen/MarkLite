//
//  BmobRole.h
//  BmobSDK
//
//  Created by Bmob on 14-5-9.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BmobObject.h"

@class BmobQuery;
@class BmobACL;


@interface BmobRole : BmobObject
/**
 *  角色名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  查询Role表
 *
 *  @return BmobQuery查询对象
 */
+(BmobQuery *)query;

/**
 *  创建BmobRole对象
 *
 *  @param name 角色名
 *
 *  @return BmobRole对象
 */
-(instancetype)initWithName:(NSString *)name;

/**
 *  创建BmobRole对象
 *
 *  @param name 角色名
 *  @param acl  ACL权限
 *
 *  @return BmobRole对象
 */
-(instancetype)initWithName:(NSString *)name acl:(BmobACL *)acl;

/**
 *  创建BmobRole对象
 *
 *  @param name 角色名
 *
 *  @return BmobRole对象
 */
+(instancetype)roleWithName:(NSString *)name;


/**
 *  创建BmobRole对象
 *
 *  @param name 角色名
 *  @param acl  ACL权限
 *
 *  @return  BmobRole对象
 */
+(instancetype)roleWithName:(NSString *)name acl:(BmobACL *)acl;

/**
 *  角色表里面的users列
 *
 *  @param relation 关联user表的关联对象
 */
-(void)addUsersRelation:(BmobRelation*)relation;

/**
 *  角色表里面的roles列
 *
 *  @param relation 关联roles表的关联对象
 */
-(void)addRolesRelation:(BmobRelation*)relation;
@end
