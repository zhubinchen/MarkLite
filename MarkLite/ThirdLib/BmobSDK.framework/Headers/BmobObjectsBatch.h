//
//  BmobBatch.h
//  BmobSDK
//
//  Created by Bmob on 14-4-21.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobObjectsBatch : NSObject

/**
 *  创建某条数据，可多次调用
 *
 *  @param className 表名
 *  @param para      要创建的列名跟列的值
 */
-(void)saveBmobObjectWithClassName:(NSString *)className parameters:(NSDictionary*)para;

/**
 *  更新某条数据，可多次调用
 *
 *  @param className 表名
 *  @param objectId  某行数据的objectId
 *  @param para      要更新的列和列的值
 */
-(void)updateBmobObjectWithClassName:(NSString*)className objectId:(NSString*)objectId parameters:(NSDictionary*)para;

/**
 *  删除某条数据，可多次调用
 *
 *  @param className 表名
 *  @param objectId  某条数据的objectId
 */
-(void)deleteBmobObjectWithClassName:(NSString *)className objectId:(NSString*)objectId;

/**
 *  批量修改数据
 *
 *  @param block 返回操作的的结果和信息
 */

-(void)batchObjectsInBackgroundWithResultBlock:(void(^)(BOOL isSuccessful,NSError *error))block;

//再加一个方法

@end
