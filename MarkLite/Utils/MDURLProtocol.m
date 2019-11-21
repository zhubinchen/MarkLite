//
//  MDURLProtocol.m
//  Markdown
//
//  Created by 朱炳程 on 2019/11/20.
//  Copyright © 2019 zhubch. All rights reserved.
//

#import "MDURLProtocol.h"
#import "NSURLProtocol+WKWebVIew.h"

static NSString* const MDURLProtocolKey = @"MDURLProtocol";

@interface MDURLProtocol () <NSURLSessionDelegate>

@property (nonnull,strong) NSURLSessionDataTask *task;

@end

@implementation MDURLProtocol

+ (void)startRegister {
    [NSURLProtocol registerClass:self];
    [NSURLProtocol wk_registerScheme:@"md"];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:@"md"]  == NSOrderedSame) {
        return ![NSURLProtocol propertyForKey:MDURLProtocolKey inRequest:request];
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    NSString *relativePath = [[request.URL.absoluteString stringByReplacingOccurrencesOfString:@"md://local/resource" withString:@""] stringByRemovingPercentEncoding];
    NSString *resPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"Resources"];
    NSString *fullPath = [resPath stringByAppendingPathComponent:relativePath];
    NSURL *url = [NSURL fileURLWithPath:fullPath];
    mutableReqeust.URL = url;

    return mutableReqeust;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest* request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:MDURLProtocolKey inRequest:request];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    self.task = [session dataTaskWithRequest:self.request];
    [self.task resume];
}

- (void)stopLoading {
    if (self.task != nil) {
        [self.task cancel];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
