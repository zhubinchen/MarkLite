//
//  BmobConfig.h
//  BmobSDK
//
//  Created by Bmob on 13-8-3.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BmobObject;
@class BmobGeoPoint;
@class BmobUser;
@class BmobFile;
@class BmobSliceResult;
@class BmobTableSchema;

#ifndef BmobSDK_BmobConfig_h
#define BmobSDK_BmobConfig_h

/**
 缓存策略
 
 kBmobCachePolicyIgnoreCache:只从网络获取数据，且数据不会缓存在本地，这是默认的缓存策略。
 
 kBmobCachePolicyCacheOnly:只从缓存读数据，如果缓存没有数据，返回一个空数组。
 
 kBmobCachePolicyNetworkOnly:只从网络获取数据，同时会在本地缓存数据。
 
 kBmobCachePolicyCacheElseNetwork:先从缓存读取数据，如果没有再从网络获取。
 
 kBmobCachePolicyNetworkElseCache:先从网络获取数据，如果没有，此处的没有可以理解为访问网络失败，再从缓存读取。
 
 kBmobCachePolicyCacheThenNetwork:先从缓存读取数据，无论结果如何都会再次从网络获取数据，在这种情况下，Block将产生两次调用。通常这种做法是先快速从缓存读取数据显示在界面，然后在后台连接网络获取最新数据，取到后再更新界面。
 */
typedef enum {
    kBmobCachePolicyIgnoreCache = 0,
    kBmobCachePolicyCacheOnly,
    kBmobCachePolicyNetworkOnly,
    kBmobCachePolicyCacheElseNetwork,
    kBmobCachePolicyNetworkElseCache,
    kBmobCachePolicyCacheThenNetwork
} BmobCachePolicy;


typedef enum {
    kBmobDirectionNorthWest = 0,    //水印图在原图的西北位置
    kBmobDirectionNorth,            //水印图在原图的正北位置
    kBmobDirectionNorthEast,        //水印图在原图的东北位置
    kBmobDirectionWest,             //水印图在原图的正西位置
    kBmobDirectionCenter,           //水印图在原图的中心位置
    kBmobDirectionEast,             //水印图在原图的正东位置
    kBmobDirectionSouthWest,        //水印图在原图的西南位置
    kBmobDirectionSouth,            //水印图在原图的正南位置
    kBmobDirectionSouthEast         //水印图在原图的东南位置
}BmobWatermarkDirection;

typedef enum {
    kBmobImageOutputBmobFile = 0,   //图片处理后返回BmobFile对象
    kBmobImageOutputStringStream    //图片处理后输出base64编码的字符串流
}BmobImageOutputType;

typedef enum {
    BmobActionTypeUpdateTable = 0,  //表更新
    BmobActionTypeUpdateRow,        //行更新
    BmobActionTypeDeleteTable,      //表删除
    BmobActionTypeDeleteRow         //行删除
}BmobActionType;

typedef enum {
    BmobSNSPlatformQQ = 0,          //qq平台
    BmobSNSPlatformSinaWeibo,        //新浪微博
    BmobSNSPlatformWeiXin,
}BmobSNSPlatform;

typedef void (^BmobObjectResultBlock)(BmobObject *object, NSError *error);
typedef void (^BmobObjectArrayResultBlock)(NSArray *array, NSError *error);
typedef void (^BmobGeoPointBlock)(BmobGeoPoint *geoPoint, NSError *error);
typedef void (^BmobBooleanResultBlock) (BOOL isSuccessful, NSError *error);
typedef void (^BmobIntegerResultBlock)(int number, NSError *error) ;
typedef void (^BmobUserResultBlock)(BmobUser *user, NSError *error);
typedef void (^BmobIdResultBlock)(id object, NSError *error);
typedef void (^BmobFileBlock)(BmobFile *file,NSError *error);
typedef void (^BmobFileBatchProgressBlock)(int index ,float progress);;
typedef void (^BmobFileBatchResultBlock)(NSArray *array,BOOL isSuccessful ,NSError *error);
typedef void (^BmobMessageResultBlock)(NSString *requestStatus,NSError *error);
typedef void (^BmobQuerySMSCodeStateResultBlock)(NSDictionary *dic,NSError *error);
typedef void (^BmobTableSchemasBlock)(BmobTableSchema *bmobTableScheme,NSError *error);
typedef void (^BmobAllTableSchemasBlock)(NSArray *tableSchemasArray,NSError *error);

UIKIT_STATIC_INLINE NSString* Version()
{
	return @"1.6.5";
}


//pro

typedef void(^BmobFileResultBlock)(BOOL isSuccessful,NSError *error,NSString *filename,NSString *url,BmobFile* file);
typedef void(^BmobFileDownloadResultBlock)(BOOL isSuccessful,NSError *error,NSString *filepath);
typedef void(^BmobProgressBlock)(CGFloat progress);
typedef void(^BmobBatchProgressBlock)();

typedef void(^BmobBatchFileUploadResultBlock)(NSArray *filenameArray,NSArray *urlArray,NSArray *bmobFileArray,NSError *error);
typedef void(^BmobIndexAndProgressBlock)(NSUInteger index,CGFloat progress);

//兼容BmobFile,可以得到直接访问url的新文件api使用的回调
typedef void(^BmobGetAccessUrlBlock)(BmobFile *file,NSError *error);
typedef void(^BmobGetAccessUrlFileBlock)(NSString *filename,NSString *url,BmobFile *file,NSError *error);
typedef void(^BmobGetAccessUrlBatchFileUploadResultBlock)(NSArray *filenameArray,NSArray *urlArray,NSArray *bmobFileArray,NSError *error);

typedef BmobFileDownloadResultBlock BmobLocalImageResultBlock;
typedef BmobBatchProgressBlock       BmobCompleteBlock ;


typedef void(^BmobSliceResultBlock)(BmobSliceResult *result);

typedef enum {
    ThumbnailImageScaleModeWidth    = 1,//指定宽，高自适应，等比例缩放;
    ThumbnailImageScaleModeHeight   = 2,//指定高， 宽自适应，等比例缩放
    ThumbnailImageScaleModeLongest  = 3,//指定最长边，短边自适应，等比例缩放;
    ThumbnailImageScaleModeShortest = 4,//指定最短边，长边自适应，等比例缩放;
    ThumbnailImageScaleModeMax      = 5,//指定最大宽高， 等比例缩放;
    ThumbnailImageScaleModeFixed    = 6 //固定宽高， 居中裁剪
}ThumbnailImageScaleMode;





#endif
