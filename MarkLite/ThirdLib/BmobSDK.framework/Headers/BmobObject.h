//
//  BmobObject.h
//  BmobSDK
//
//  Created by Bmob on 13-8-1.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"


@class BmobRelation;
@class BmobACL;

@interface BmobObject : NSObject


/**
 *	 BmobObject对象的id
 */
@property(nonatomic,copy)NSString *objectId;


/**
 *	 BmobObject对象的最后更新时间
 */
@property(nonatomic,strong)NSDate *updatedAt;

/**
 *	 BmobObject对象的生成时间
 */
@property(nonatomic,strong)NSDate *createdAt;

/**
 *  BmobObject对象的表名
 */
@property(nonatomic,copy)NSString * className;


/**
 *  权限控制里列表
 */
@property(nonatomic,strong)BmobACL *ACL;


/**
 *	创建一个带有className的BmobObject对象
 *
 *	@param	className	表示对象名称(类似数据库表名)
 *
 *	@return	BmobObject
 */
+(instancetype )objectWithClassName:(NSString*)className;


/**
 *  创建一个带有className 和objectId的BmobObject对象
 *
 *  @param className 表名
 *  @param objectId  对象的id
 *
 *  @return BmobObject对象
 */
+(instancetype)objectWithoutDatatWithClassName:(NSString*)className objectId:(NSString *)objectId;

/**
 *	通过对象名称（类似数据库表名）初始化BmobObject对象
 *
 *	@param	className	表示对象名称(类似数据库表名)
 *
 *	@return	BmobObject
 */
-(id)initWithClassName:(NSString*)className;



/**
 *  从字典创建BmobObject
 *
 *  @param dictionary 字典
 *
 *  @return BmobObject 对象
 */
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *	向BmobObject对象添加数据
 *
 *	@param	obj	数据
 *	@param	aKey	键
 */
-(void)setObject:(id)obj forKey:(NSString*)aKey;


/**
 *  为列创建关联关系
 *
 *  @param relation 关联关系
 *  @param key      列
 */
-(void)addRelation:(BmobRelation *)relation forKey:(id)key;

/**
 *  批量向BmobObject添加数据,可与 -(void)setObject:(id)obj forKey:(NSString*)aKey;一同使用
 *
 *  @param dic 数据
 */
-(void)saveAllWithDictionary:(NSDictionary*)dic;

/**
 *	得到BombObject对象某个列的值
 *
 *	@param	aKey	列名
 *
 *	@return	该列的值
 */
-(id)objectForKey:(id)aKey;


/**
 *  删除BmobObject对象的某列的值
 *
 *  @param key 列名
 */
-(void)deleteForKey:(id)key;


#pragma mark  array add and remove
/**
 *  向给定的列添加数组
 *
 *  @param objects 想要添加的数组
 *  @param key     给定的列名
 */
-(void)addObjectsFromArray:(NSArray *)objects forKey:(NSString *)key;

/**
 *  向给定的列添加数组，只会在原本数组字段中没有这些对象的情形下才会添加入数组
 *
 *  @param objects 想要添加的数组
 *  @param key     给定的列名
 */
-(void)addUniqueObjectsFromArray:(NSArray *)objects forKey:(NSString *)key;

/**
 *  从一个数组字段的值内移除指定的数组中的所有对象
 *
 *  @param objects 想要移除的数组
 *  @param key     给定的列名
 */
-(void)removeObjectsInArray:(NSArray *)objects forKey:(NSString *)key;




#pragma mark increment and decrment

/**
 *  列的值+1
 *
 *  @param key 列名
 */
-(void)incrementKey:(NSString *)key;

/**
 *  列的值加 amount
 *
 *  @param key    列的值
 *  @param amount 增加的数值
 */
-(void)incrementKey:(NSString *)key byAmount:(NSInteger )amount;

/**
 *  列的值-1
 *
 *  @param key 列名
 */
-(void)decrementKey:(NSString *)key;

/**
 *  列的值减 amount
 *
 *  @param key    列的值
 *  @param amount 减去的数值
 */
-(void)decrementKey:(NSString *)key byAmount:(NSInteger )amount;



#pragma mark networking

/**
 *	后台保存BmobObject对象，没有返回结果
 */
-(void)saveInBackground;

/**
 *	后台保存BmobObject对象，返回保存的结果
 *
 *	@param	block	返回保存的结果是成功还是失败
 */
-(void)saveInBackgroundWithResultBlock:(BmobBooleanResultBlock)block;

/**
 *	后台更新BmobObject对象，没有返回结果
 */
-(void)updateInBackground;

/**
 *	后台更新BmobObject对象
 *
 *	@param	block	返回更新的结果是成功还是失败
 */
-(void)updateInBackgroundWithResultBlock:(BmobBooleanResultBlock)block;

/**
 *	后台删除BmobObject对象，没有返回结果
 */
-(void)deleteInBackground;

/**
 *	后台删除BmobObject对象
 *
 *	@param	block	返回删除的结果是成功还是失败
 */
-(void)deleteInBackgroundWithBlock:(BmobBooleanResultBlock)block;


- (BOOL)isEqual:(BmobObject*)object;
- (NSString*)description;

@end
