//
//  HttpRequest.h
//  test
//
//  Created by zhubch on 14-10-29.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestDelegate;

typedef enum : NSUInteger {
    Timeout,//网络超时
    WrongRequest,//请求错误
    Other,//其他错误
} ErrorCode;

/**
 *  请求完成的回调block
 *
 *  @param response 响应的data
 */
typedef void(^CompletedCallBack)(NSData *response);

/**
 *  下载进度的回调block
 *
 *  @param response 响应的data
 */
typedef void(^ProgressCallBack)(float percent);

/**
 *  请求失败的回调block
 *
 *  @param errorCode 错误码   
 */
typedef void(^FailedCallBack)(ErrorCode code);


@interface HttpRequest : NSObject

@property (strong,nonatomic) NSString *url;

@property (strong,nonatomic) id body;

@property (nonatomic,assign) NSUInteger timeoutInterval;

@property (copy,nonatomic) CompletedCallBack completedCallBack;

@property (copy,nonatomic) FailedCallBack failedCallBack;

@property (copy,nonatomic) ProgressCallBack progressCallBack;

@property (weak,nonatomic) id<RequestDelegate> delegate;

/**
 *  是否正在请求
 */
@property (assign,nonatomic,readonly) BOOL isLoading;

/**
 *  方便以后请求，不需要再输完整的URL。
 *
 *  @param url 服务器地址
 */
+ (void)initializeWithServerUrl:(NSString*)url;

+ (void)setToken:(NSString*)token;

+ (void)setTimeoutInterval:(NSUInteger)interval;

/**
 *  实例化对象
 *
 *  @param url      完整的URL
 *  @param method   请求方式。默认GET请求
 *  @param useCache 是否优先使用缓存
 *
 *  @return 
 */
- (id)initWithUrl:(NSString*)url Method:(NSString*)method UseCache:(BOOL) useCache;

- (void)start;

/**
 *  下载文件
 *
 *  @param url      URL
 *  @param progress 下载进度改变后调用的block
 *  @param succese 下载成功后调用的block
 *  @param failed  下载失败后调用的block
 */
+ (void)downloadWithUrl:(NSString *)url progress:(ProgressCallBack)progress succese:(CompletedCallBack)succese failed:(FailedCallBack)failed;

/**
 *  发起一个get请求
 *
 *  @param url      URL
 *  @param useCache 是否优先使用缓存
 *  @param succese 请求成功后调用的block
 *  @param failed  请求失败后调用的block
 */
+ (void)getWithUrl:(NSString*)url UseCache:(BOOL)useCache Succese:(CompletedCallBack)succese Failed:(FailedCallBack)failed;

/**
 *  发起一个post请求
 *
 *  @param url      URL
 *  @param body     请求体，Json字符串
 *  @param succese 请求成功后调用的block
 *  @param failed  请求失败后调用的block
 */
+ (void)postWithUrl:(NSString*)url Body:(id)body Succese:(CompletedCallBack)succese Failed:(FailedCallBack)failed;


/**
 *
 *  发起一个delete请求
 *
 *  @param url     URL
 *  @param body    请求提，字典
 *  @param succese 请求成功后调用的block
 *  @param failed  请求失败后调用的block
 */
+ (void)deleteWithUrl:(NSString *)url Body:(id)body Succese:(CompletedCallBack)succese Failed:(FailedCallBack)failed;

@end

/**
 *  声明了一些请求有关的回调方法
 */
@protocol RequestDelegate <NSObject>

- (void)request:(HttpRequest *)request CompletedWithResponse:(NSData*) response;

- (void)request:(HttpRequest *)request FailedWithError:(ErrorCode)code;

- (void)request:(HttpRequest *)request recievedNewData:(NSData*)newData;

@end
