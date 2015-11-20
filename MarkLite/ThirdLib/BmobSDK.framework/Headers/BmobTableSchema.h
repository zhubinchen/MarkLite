//
//  BmobTableScheme.h
//  BmobSDK
//
//  Created by limao on 15/7/24.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobTableSchema : NSObject

@property (nonatomic,readonly,copy) NSString *className; /**< 表名 */

@property (nonatomic,readonly,copy) NSDictionary *fields; /**< 表结构，结构{@"列名":结构字典} */

/**
 *  指定初始化方法
 *
 *  @param bmobTableSchemaDic 初始化用的dic,结构为@{@"className":@"name",@"fields":dic}
 *
 *  @return BmobTableSchema对象
 */
-(instancetype)initWithBmobTableSchemaDic:(NSDictionary*)bmobTableSchemaDic;
@end
