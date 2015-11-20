//
//  BmobRelation.h
//  BmobSDK
//
//  Created by Bmob on 14-4-16.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobObject.h"


@interface BmobRelation : NSObject

/**
 *  创建BmobRelation对象实例
 *
 *  @return BmobRelation对象实例
 */
+(instancetype)relation;

/**
 *  添加关联关系
 *
 *  @param object 添加关系的对象
 */
-(void)addObject:(BmobObject *)object;

/**
 *  移除关联关系
 *
 *  @param object 移除关系的对象
 */
-(void)removeObject:(BmobObject *)object;
@end
