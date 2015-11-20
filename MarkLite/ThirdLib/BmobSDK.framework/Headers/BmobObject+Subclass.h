//
//  BmobObject+Subclass.h
//  PushDemo
//
//  Created by Bmob on 15/5/27.
//  Copyright (c) 2015年 unknown. All rights reserved.
//

#import "BmobObject.h"
#import "BmobQuery.h"

@interface BmobObject (Subclass)

+(BmobQuery *)query;
/**
 *  保存数据
 */
-(void)sub_saveInBackground;

/**
 *  保存数据
 *
 *  @param block 结果回调
 */
-(void)sub_saveInBackgroundWithResultBlock:(BmobBooleanResultBlock)block;

/**
 *  更新数据
 */
-(void)sub_updateInBackground;

/**
 *  更新数据
 *
 *  @param block 结果回调
 */
-(void)sub_updateInBackgroundWithResultBlock:(BmobBooleanResultBlock)block;


/**
 *  把bmobobject对象转成子类，对BmobObject，BmobUser，BmobRole，BmobInstallation的子类有效
 *
 *  @param obj    BmobObject对象
 *  @param kClass 父类的class
 *
 *  @return 子类的对象
 */
-(instancetype)initFromBmobObject:(BmobObject *)obj;

@end

