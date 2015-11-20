//
//  BmobImage.h
//  BmobSDK
//
//  Created by Bmob on 14-5-23.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"



@interface BmobImage : NSObject



/**
*  指定宽， 高自适应，等比例缩放
*
*  @param width     限定图片的宽度
*  @param quality   图片的质量1~100
*  @param imageUrl  原图片的地址
*  @param type      返回类型
*  @param block     生成返回结果和信息
*/
+(void)thumbnailImageBySpecifiesTheWidth:(NSInteger)width
                                 quality:(NSInteger)quality
                          sourceImageUrl:(NSString*)imageUrl
                              outputType:(BmobImageOutputType)type
                             resultBlock:(BmobIdResultBlock)block;

/**
 *  指定高， 宽自适应，等比例缩放
 *
 *  @param height   限定图片的高度
 *  @param quality  图片的质量1~100
 *  @param imageUrl 原图片的地址
 *  @param type     返回类型
 *  @param block    生成的BmobFile文件，及错误信息
 */
+(void)thumbnailImageBySpecifiesTheHeight:(NSInteger)height
                                  quality:(NSInteger)quality
                           sourceImageUrl:(NSString*)imageUrl
                               outputType:(BmobImageOutputType)type
                              resultBlock:(BmobIdResultBlock)block;

/**
 *  指定最长边，短边自适应，等比例缩放
 *
 *  @param longEdge   指定图片的最长边的大小
 *  @param quality  图片的质量1~100
 *  @param imageUrl 原图片的地址
 *  @param type     返回类型
 *  @param block    生成的BmobFile文件，及错误信息
 */
+(void)thumbnailImageBySpecifiesTheLength:(NSInteger)longEdge
                                  quality:(NSInteger)quality
                           sourceImageUrl:(NSString*)imageUrl
                               outputType:(BmobImageOutputType)type
                              resultBlock:(BmobIdResultBlock)block;

/**
 *  指定最短边，长边自适应，等比例缩放
 *
 *  @param shortEdge    指定图片的最短边的大小
 *  @param quality  图片的质量1~100
 *  @param imageUrl 原图片的地址
 *  @param type     返回类型
 *  @param block    生成的BmobFile文件，及错误信息
 */
+(void)thumbnailImageBySpecifiesTheShort:(NSInteger)shortEdge
                                 quality:(NSInteger)quality
                          sourceImageUrl:(NSString*)imageUrl
                              outputType:(BmobImageOutputType)type
                             resultBlock:(BmobIdResultBlock)block;

/**
 *  指定最大宽高， 等比例缩放
 *
 *  @param width    指定宽度
 *  @param height   指定高度
 *  @param quality  图片的质量1~100
 *  @param imageUrl 原图片的地址
 *  @param type     返回类型
 *  @param block    生成的BmobFile文件，及错误信息
 */
+(void)thumbnailImageBySpecifiesTheWidth:(NSInteger)width
                                  height:(NSInteger)height
                                 quality:(NSInteger)quality
                          sourceImageUrl:(NSString*)imageUrl
                              outputType:(BmobImageOutputType)type
                             resultBlock:(BmobIdResultBlock)block;

/**
 *  固定宽高， 居中裁剪
 *
 *  @param width    指定要裁剪的宽度
 *  @param height   指定要裁剪的高度
 *  @param quality  图片的质量1~100
 *  @param imageUrl 原图片的地址
 *  @param type     返回类型
 *  @param block    生成的BmobFile文件，及错误信息
 */


+(void)cutImageBySpecifiesTheWidth:(NSInteger)width
                            height:(NSInteger)height
                           quality:(NSInteger)quality
                    sourceImageUrl:(NSString*)imageUrl
                        outputType:(BmobImageOutputType)type
                       resultBlock:(BmobIdResultBlock)block;

/**
 *  图片添加水印
 *
 *  @param sourceImageUrl    原图的路径
 *  @param watermarkImageUrl 水印图的路径
 *  @param dissolve          透明度,范围在0-255
 *  @param direction         水印的位置
 *  @param x                 横轴边距，单位为像素，缺省为10
 *  @param y                 纵轴边距，单位为像素，缺省为10
 *  @param type              返回类型
 *  @param block             生成的BmobFile文件，及错误信息
 */
+(void)watermarkImageWithSourceImageUrl:(NSString*)sourceImageUrl
                      watermarkImageUrl:(NSString*)watermarkImageUrl
                               dissolve:(NSInteger)dissolve
                              direction:(BmobWatermarkDirection)direction
                                      x:(NSInteger)x
                                      y:(NSInteger)y
                             outputType:(BmobImageOutputType)type
                            resultBlock:(BmobIdResultBlock)block;



@end
