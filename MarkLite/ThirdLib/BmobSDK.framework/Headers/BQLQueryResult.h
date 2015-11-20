//
//  BQLQueryResult.h
//  BmobSDK
//
//  Created by limao on 15/5/11.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BQLQueryResult : NSObject
/**
 *  查询结果的 className
 */
@property(nonatomic, strong) NSString *className;

/**
 *  查询的结果 BmobObject 对象列表
 */
@property(nonatomic, strong) NSArray *resultsAry;

/**
 *  查询 count 结果, 只有使用 select count(*) ... 时该值信息才是有效的
 */
@property(nonatomic) int count;

- (NSString*)description;
- (BOOL)isEqual:(BQLQueryResult*)object;

@end

//统计查询使用的回调
typedef void (^BmobBQLArrayResultBlock)(NSArray *result,NSError *error);
//非统计查询使用的回调
typedef void (^BmobBQLObjectResultBlock)(BQLQueryResult *result,NSError *error);
