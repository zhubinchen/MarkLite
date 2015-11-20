//
//  BmobFile.h
//  NSStreamTest
//
//  Created by Bmob on 14-11-4.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"


/**
 *  提供文件相关功能接口
 */
@interface BmobProFile : NSObject




/**
 *  下载文件
 *
 *  @param filename      文件名
 *  @param block         下载的结果
 *  @param progressBlock 下载的进度
 */
+(void)downloadFileWithFilename:(NSString *)filename
                          block:(BmobFileDownloadResultBlock)block
                       progress:(BmobProgressBlock)progressBlock;

/**
 *  存放下载文件的图片的文件夹的大小
 *
 *  @return 文件夹的大小
 */
+(long long)cacheFizesSize;

/**
 *  清除下载的图片跟缩略图图片
 */
+(void)cleanCache;
/**
 *  缩略图处理
 *
 *  @param filename 图片的文件名
 *  @param ruleID   规格ID
 *  @param block    处理的结果信息，包括是否成功，错误信息，文件名，文件的url地址
 */
+(void)thumbnailImageWithFilename:(NSString *)filename
                           ruleID:(NSUInteger)ruleID
                      resultBlock:(BmobFileResultBlock)block;

/**
 *  本地缩略图处理
 *
 *  @param filepath 图片的路径
 *  @param ruleID   规格ID
 *  @param block    处理的结果信息，包括是否成功，错误信息，文件的地址
 */
+(void)localThumbnailImageWithFilepath:(NSString *)filepath
                                ruleID:(NSUInteger)ruleID
                           resultBlock:(BmobLocalImageResultBlock)block;

/**
 *  本地缩略图处理
 *
 *  @param filepath 图片的路径
 *  @param m        图片处理的模式
 *  @param w        宽度
 *  @param h        高度
 *  @param block    处理的结果信息，包括是否成功，错误信息，文件的地址
 */
+(void)localThumbnailImageWithFilepath:(NSString *)filepath
                                  mode:(ThumbnailImageScaleMode )m
                                 width:(CGFloat)w
                                height:(CGFloat)h
                           resultBlock:(BmobLocalImageResultBlock)block;

/**
 *  开启安全验证后的url签名
 *
 *  @param filename  文件名
 *  @param urlString 文件的url地址
 *  @param validTime 有效时间 单位：秒
 *  @param a         accessKey
 *  @param s         secretKey
 *
 *  @return 签名后的url地址
 */
+(NSString *)signUrlWithFilename:(NSString *)filename
                             url:(NSString *)urlString
                       validTime:(int)validTime
                       accessKey:(NSString *)a
                       secretKey:(NSString *)s;

# pragma mark -  得到访问url及删除上传文件
/**
 *  得到直接访问文件的url
 *
 *  @param uuid  上传文件时得到的uuid
 *  @param block 返回的回调
 */
+(void) getFileAcessUrlWithFileName:(NSString*)fileName
                       callBack:(BmobGetAccessUrlBlock)block;

/**
 *  删除已上传文件
 *
 *  @param uuid  上传文件时得到的uuid
 *  @param block 返回的回调
 */
+(void) deleteFileWithFileName:(NSString*)fileName
                  callBack:(BmobBooleanResultBlock)block;


/**
 *  上传文件
 *
 *  @param path          路径
 *  @param block         上传的结果
 *  @param progressBlock 上传的进度
 */
+(void)uploadFileWithPath:(NSString *)path
                    block:(BmobFileResultBlock)block
                 progress:(BmobProgressBlock)progressBlock;

/**
 *  上传文件
 *
 *  @param filename      文件名(带后缀)
 *  @param data          文件的数据
 *  @param block         上传的结果
 *  @param progressBlock 上传的进度
 */
+(void)uploadFileWithFilename:(NSString *)filename
                     fileData:(NSData *)data
                        block:(BmobFileResultBlock)block
                     progress:(BmobProgressBlock)progressBlock;

/**
 *  批量上传文件
 *
 *  @param array 文件的路径
 */
+(void)uploadFilesWithPaths:(NSArray *)array
                resultBlock:(BmobBatchFileUploadResultBlock)block
                   progress:(BmobIndexAndProgressBlock)progress;


/**
 *  批量上传文件
 *
 *  @param dataArray 数组中存放的NSDictionary，NSDictionary里面的格式为@{@"filename":@"你的文件名",@"data":文件的data}
 *  文件名需要带后缀
 *  @param block     上传文件的结果回调
 *  @param progress  上传文件的进度回调，表示当前是第几个，进度多少
 */
+(void)uploadFilesWithDatas:(NSArray *)dataArray
                resultBlock:(BmobBatchFileUploadResultBlock)block
                   progress:(BmobIndexAndProgressBlock)progress;
@end
