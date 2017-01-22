//
//  ZHRequest.h
//  test
//
//  Created by Bingcheng on 14-10-29.
//  Copyright (c) 2014年 Bingcheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZHRequestDelegate;

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
 *  请求失败的回调block
 *
 *  @param errorCode 错误码   
 */
typedef void(^FailedCallBack)(ErrorCode code);


@interface ZHRequest : NSObject

@property (strong,nonatomic) NSString *url;

@property (strong,nonatomic) id body;

@property (nonatomic,assign) NSUInteger timeoutInterval;

@property (copy,nonatomic) CompletedCallBack completedCallBack;

@property (copy,nonatomic) FailedCallBack failedCallBack;

@property (weak,nonatomic) id<ZHRequestDelegate> delegate;

/**
 *  是否正在请求
 */
@property (assign,nonatomic,readonly) BOOL isLoading;

/**
 *  可以在程序入口处设置，方便以后请求，不需要再输完整的URL。
 *
 *  @param url 服务器地址
 */
+ (void)initializeWithServerUrl:(NSString*)url;

/**
 *  添加token验证，如果有必要的话。
 *
 *  @param token token
 */
+ (void)setToken:(NSString*)token;

/**
 *  设置最长等待时间。
 *
 *  @param interval 超过这个时间没收到响应就返回超时错误
 */
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
 *  @param body     请求体
 *  @param succese 请求成功后调用的block
 *  @param failed  请求失败后调用的block
 */
+ (void)postWithUrl:(NSString*)url Body:(id)body Succese:(CompletedCallBack)succese Failed:(FailedCallBack)failed;


/**
 *
 *  发起一个delete请求
 *
 *  @param url     URL
 *  @param body    请求体
 *  @param succese 请求成功后调用的block
 *  @param failed  请求失败后调用的block
 */
+ (void)deleteWithUrl:(NSString *)url Body:(id)body Succese:(CompletedCallBack)succese Failed:(FailedCallBack)failed;

@end

/**
 *  请求相关的回调方法
 */
@protocol ZHRequestDelegate <NSObject>

- (void)request:(ZHRequest *)request CompletedWithResponse:(NSData*) response;

- (void)request:(ZHRequest *)request FailedWithError:(ErrorCode)code;

- (void)request:(ZHRequest *)request recievedNewData:(NSData*)newData;

@end
