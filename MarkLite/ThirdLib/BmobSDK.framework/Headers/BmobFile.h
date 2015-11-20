//
//  BmobFile.h
//  BmobSDK
//
//  Created by Bmob on 13-9-10.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"

@interface BmobFile : NSObject



/**
 *	文件名
 */
@property(nonatomic,copy)NSString  *name;

/**
 *	文件的地址
 */
@property(nonatomic,copy)NSString  *url;

/**
 *	文件的组名
 */
@property(nonatomic,copy)NSString  *group;



/*!
 DEPRECATED: 使用-(id)initWithFilePath:(NSString*)filePath;代替
 */
-(id)initWithClassName:(NSString*)className withFilePath:(NSString*)filePath;

/*!
 DEPRECATED: 使用-(id)initWithFileName:(NSString*)fileName  withFileData:(NSData*)data;代替
 */
-(id)initWithClassName:(NSString *)className  withFileName:(NSString*)fileName  withFileData:(NSData*)data;

/**
 *  创建BmobFile对象
 *  可代替-(id)initWithClassName:(NSString*)className withFilePath:(NSString*)filePath;
 *  @param filePath 文件路径
 *
 *  @return BmobFile对象实例
 */
-(id)initWithFilePath:(NSString*)filePath;

/**
 *  创建BmobFile对象
 *  可代替-(id)initWithClassName:(NSString *)className  withFileName:(NSString*)fileName  withFileData:(NSData*)data;
 *  @param fileName 文件名称，请加上后缀
 *  @param data     二进制数据
 *
 *  @return BmobFile对象实例
 */
-(id)initWithFileName:(NSString*)fileName  withFileData:(NSData*)data;

/**
 *	上传文件并保存,使用同步的方法保存，故
 *  请勿在GCD使用该方法
 */
-(BOOL)save;

/**
 *  异步上传文件并保存
 *
 *  @param block 返回保存结果与信息，如果保存成功，则无返回信息
 */
-(void)saveInBackground:(BmobBooleanResultBlock)block;

/**
 *  异步上传文件并保存
 *
 *  @param block         返回保存结果与信息，如果保存成功，则无返回信息
 *  @param progressBlock 上传进度
 */
-(void)saveInBackground:(BmobBooleanResultBlock)block withProgressBlock:(void(^)(float progress))progressBlock;


/**
 *  以分片的方式上传文件
 *
 *  @param block 返回保存结果与信息，如果保存成功，则无返回信息
 */
-(void)saveInBackgroundByDataSharding:(BmobBooleanResultBlock)block;

/**
 *  以分片的方式上传文件
 *
 *  @param block         返回保存的结果与信息，如果保存成功则无返回信息
 *  @param progressBlock 上传文件的进度
 */
-(void)saveInBackgroundByDataSharding:(BmobBooleanResultBlock)block progressBlock:(void(^)(float progress))progressBlock;

/**
 *  异步请求删除文件
 */
-(void)deleteInBackground;

/**
 *  异步请求删除文件
 *
 *  @param block 返回删除结果与信息，如果删除成功，则无返回信息
 */
-(void)deleteInBackground:(BmobBooleanResultBlock)block;

/**
 *  取消上传
 */
-(void)cancel;

/**
 *  批量上传文件
 *
 *  @param pathArray 路径数组
 *  @param progress  当前第几个，当前文件的进度
 *  @param block     BmobFile数组，上传结果和失败信息
 */
+(void)filesUploadBatchWithPaths:(NSArray *)pathArray
                   progressBlock:(BmobFileBatchProgressBlock)progress
                     resultBlock:(BmobFileBatchResultBlock)block;


/**
 *  批量上传文件
 *
 *  @param dataArray 数组中存放的NSDictionary，NSDictionary里面的格式为@{@"filename":@"你的文件名",@"data":图片的data}
 *  文件名需要带后缀
 *  @param progress  当前第几个，当前文件的进度
 *  @param block     BmobFile数组，上传结果和失败信息
 */
+(void)filesUploadBatchWithDataArray:(NSArray *)dataArray
                       progressBlock:(BmobFileBatchProgressBlock)progress
                         resultBlock:(BmobFileBatchResultBlock)block;

@end
