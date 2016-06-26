//
//  ZHRequest.m
//  test
//
//  Created by zhubch on 14-10-29.
//  Copyright (c) 2014年 zhubch. All rights reserved.
//

#import "ZHRequest.h"

static NSString *serverUrl = @"";
static NSString *userToken = @"";
static NSInteger timeoutInterval = 10;

@interface ZHRequest () <NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (strong,nonatomic) NSMutableData *responseData;

@property (strong,nonatomic) NSMutableURLRequest *request;

@end

@implementation ZHRequest

+ (void)setToken:(NSString *)token
{
    if (token.length) {
        userToken = token;
    }
}

+ (void)setTimeoutInterval:(NSUInteger)interval
{
    timeoutInterval = interval;
}

+ (void)initializeWithServerUrl:(NSString *)url
{
    serverUrl = url;
}

- (id)initWithUrl:(NSString *)url Method:(NSString *)method UseCache:(BOOL)useCache
{
    if (self = [super init]) {
        
        if (![url hasPrefix:@"http"]) {
            self.url = [NSString stringWithFormat:@"%@%@",serverUrl,url];
        }else {
            self.url = url;
        }
        
//        NSLog(@"%@",self.url);
        _isLoading = NO;

        self.responseData = [[NSMutableData alloc]init];
        
        if (useCache) {
            self.request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:timeoutInterval];
        } else {
           self.request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:timeoutInterval];
        }
        
        self.request.HTTPMethod = method;
        [self.request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [self.request addValue:@"2" forHTTPHeaderField:@"apiVer"];
        if (userToken.length) {
            [self.request addValue:userToken forHTTPHeaderField:@"token"];
        }
    }
    
    return self;
}

- (void)start
{
    if (self.isLoading) {
        return;
    }
    
    if (_timeoutInterval > 0) {
        self.request.timeoutInterval = _timeoutInterval;
    }
    
    if ([self.request.HTTPMethod isEqualToString:@"POST"]||[self.request.HTTPMethod isEqualToString:@"PUT"]) {
        if ([self.body isKindOfClass:[NSData class]]) {
            self.request.HTTPBody = self.body;
        }
        if ([self.body isKindOfClass:[NSString class]]) {
            self.request.HTTPBody = [self.body dataUsingEncoding:NSUTF8StringEncoding];
        }
        if ([self.body isKindOfClass:[NSDictionary class]] || [self.body isKindOfClass:[NSArray class]]) {
            self.request.HTTPBody = [NSJSONSerialization dataWithJSONObject:self.body options:0 error:nil];
        }
    }
    
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:self.request delegate:self];
    [conn start];
    
    _isLoading = YES;
}

#pragma mark 简便类方法

+ (void)getWithUrl:(NSString *)url UseCache:(BOOL)useCache Succese:(CompletedCallBack)succese Failed:(FailedCallBack)failed
{
    ZHRequest *request = [[ZHRequest alloc]initWithUrl:url Method:@"GET" UseCache:useCache];
    request.completedCallBack = succese;
    request.failedCallBack = failed;
    [request start];
}

+ (void)postWithUrl:(NSString *)url Body:(id)body Succese:(CompletedCallBack)succese Failed:(FailedCallBack)failed
{
    ZHRequest *request = [[ZHRequest alloc]initWithUrl:url Method:@"POST" UseCache:NO];
    request.body = body;
    request.completedCallBack = succese;
    request.failedCallBack = failed;
    [request start];
}

+ (void)deleteWithUrl:(NSString *)url Body:(id)body Succese:(CompletedCallBack)succese Failed:(FailedCallBack)failed
{
    ZHRequest *request = [[ZHRequest alloc]initWithUrl:url Method:@"DELETE" UseCache:NO];
    request.body = body;
    request.completedCallBack = succese;
    request.failedCallBack = failed;
    [request start];
}

#pragma mark connectionData代理方法

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _isLoading = NO;

    if (self.completedCallBack) {
        self.completedCallBack(self.responseData);
    }
    
    [self.delegate request:self CompletedWithResponse:self.responseData];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{        
    if (self.failedCallBack) {
        self.failedCallBack(Timeout);
    }
    
    if ([self.delegate respondsToSelector:@selector(request:FailedWithError:)]){
        [self.delegate request:self FailedWithError:Timeout];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _isLoading = YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount]== 0) {

        NSURLCredential* cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:cre forAuthenticationChallenge:challenge];
    }
}

@end
