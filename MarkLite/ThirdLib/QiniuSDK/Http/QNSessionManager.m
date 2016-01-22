//
//  QNHttpManager.m
//  QiniuSDK
//
//  Created by bailong on 14/10/1.
//  Copyright (c) 2014年 Qiniu. All rights reserved.
//

#import "AFNetworking.h"

#import "QNConfiguration.h"
#import "QNSessionManager.h"
#import "QNUserAgent.h"
#import "QNResponseInfo.h"
#import "QNAsyncRun.h"
#import "QNDns.h"
#import "HappyDNS.h"
#import "QNStats.h"
#import "QNSystem.h"

#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000) || (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090)

@interface QNProgessDelegate : NSObject
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
@property (nonatomic, strong) QNInternalProgressBlock progressBlock;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) NSURLSessionUploadTask *task;
@property (nonatomic, strong) QNCancelBlock cancelBlock;
- (instancetype)initWithProgress:(QNInternalProgressBlock)progressBlock;
@end

static NSURL *buildUrl(NSString *host, NSNumber *port, NSString *path){
	port = port == nil ?[NSNumber numberWithInt:80] : port;
	NSString *p = [[NSString alloc] initWithFormat:@"http://%@:%@%@", host, port, path];
	return [[NSURL alloc] initWithString:p];
}

static BOOL needRetry(NSHTTPURLResponse *httpResponse, NSError *error){
	if (error != nil) {
		return error.code < -1000;
	}
	if (httpResponse == nil) {
		return YES;
	}
	int status = (int)httpResponse.statusCode;
	return status >= 500 && status < 600 && status != 579;
}

@implementation QNProgessDelegate
- (instancetype)initWithProgress:(QNInternalProgressBlock)progressBlock {
	if (self = [super init]) {
		_progressBlock = progressBlock;
		_progress = nil;
	}

	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context; {
	if (context == nil || object == nil) {
		return;
	}

	NSProgress *progress = (NSProgress *)object;

	void *p = (__bridge void *)(self);
	if (p == context) {
		_progressBlock(progress.completedUnitCount, progress.totalUnitCount);
		if (_cancelBlock && _cancelBlock()) {
			[_task cancel];
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end

@interface QNSessionManager ()
@property (nonatomic) AFHTTPSessionManager *httpManager;
@property UInt32 timeout;
@property (nonatomic, strong) QNUrlConvert converter;
@property bool noProxy;
@property (nonatomic) QNDnsManager *dns;
@property (nonatomic, strong) QNStats *statsManager;
@end

@implementation QNSessionManager

- (instancetype)initWithProxy:(NSDictionary *)proxyDict
                      timeout:(UInt32)timeout
                 urlConverter:(QNUrlConvert)converter
              upStatsDropRate:(float)dropRate
                          dns:(QNDnsManager*)dns{
	if (self = [super init]) {
		if (proxyDict != nil) {
			_noProxy = NO;
		}
		else {
			_noProxy = YES;
		}
        
        _httpManager = [QNSessionManager httpManagerWithProxy:proxyDict];
        
		_timeout = timeout;
		_converter = converter;
		_dns = dns;
		_statsManager = [[QNStats alloc]initWithPushInterval:0 dropRate:dropRate statsHost:nil dns:dns];
	}

	return self;
}

+ (AFHTTPSessionManager*) httpManagerWithProxy:(NSDictionary *)proxyDict{
    NSURLSessionConfiguration *configuration =  [NSURLSessionConfiguration defaultSessionConfiguration];
    if (proxyDict != nil) {
        configuration.connectionProxyDictionary = proxyDict;
    }

    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return httpManager;
}

- (instancetype)init {
	return [self initWithProxy:nil timeout:60 urlConverter:nil upStatsDropRate:-1 dns:nil];
}

+ (QNResponseInfo *)buildResponseInfo:(NSHTTPURLResponse *)response
                            withError:(NSError *)error
                         withDuration:(double)duration
                         withResponse:(NSData *)body
                             withHost:(NSString *)host
                               withIp:(NSString *)ip {
	QNResponseInfo *info;

	if (response) {
		int status =  (int)[response statusCode];
		NSDictionary *headers = [response allHeaderFields];
		NSString *reqId = headers[@"X-Reqid"];
		NSString *xlog = headers[@"X-Log"];
		NSString *xvia = headers[@"X-Via"];
		if (xvia == nil) {
			xvia = headers[@"X-Px"];
		}
		if (xvia == nil) {
			xvia = headers[@"Fw-Via"];
		}
		info = [[QNResponseInfo alloc] init:status withReqId:reqId withXLog:xlog withXVia:xvia withHost:host withIp:ip withDuration:duration withBody:body];
	}
	else {
		info = [QNResponseInfo responseInfoWithNetError:error host:host duration:duration];
	}
	return info;
}

- (void)      sendRequest:(NSMutableURLRequest *)request
                withStats:(NSMutableDictionary *)stats
        withCompleteBlock:(QNCompleteBlock)completeBlock
        withProgressBlock:(QNInternalProgressBlock)progressBlock
          withCancelBlock:(QNCancelBlock)cancelBlock {
	__block NSDate *startTime = [NSDate date];

	NSString *domain = request.URL.host;

	setStat(stats, @"domain", domain);

	NSString *u = request.URL.absoluteString;
	NSURL *url = request.URL;
	NSArray *ips = nil;
	if (_converter != nil) {
		url = [[NSURL alloc] initWithString:_converter(u)];
		request.URL = url;
		domain = url.host;
	} else if (_noProxy && _dns != nil && [url.scheme isEqualToString:@"http"]) {
		ips = [_dns queryWithDomain:[[QNDomain alloc] init:domain hostsFirst:NO hasCname:YES maxTtl:1000]];
		double duration = [[NSDate date] timeIntervalSinceDate:startTime];

		setStat(stats, @"dt", [NSNumber numberWithInt:(int)(duration*1000)]);

		if (ips == nil || ips.count == 0) {
			NSError *error = [[NSError alloc] initWithDomain:domain code:-1003 userInfo:@{ @"error":@"unkonwn host" }];

			QNResponseInfo *info = [QNResponseInfo responseInfoWithNetError:error host:domain duration:duration];
			NSLog(@"failure %@", info);

			setStat(stats, @"rst", @"ErrDomainNotFound");

			completeBlock(info, nil);
			return;
		}
	}
	[self sendRequest2:request withStats:stats withCompleteBlock:completeBlock withProgressBlock:progressBlock withCancelBlock:cancelBlock withIpArray:ips withIndex:0 withDomain:domain withRetryTimes:3 withStartTime:startTime];
}


- (void) recordRst:(NSMutableDictionary *)stats
          response:(NSHTTPURLResponse *)response
             error:(NSError *)error
                st:(NSDate *)st {

	if (!stats) {
		return;
	}
	if (response) {
		setStat(stats, @"rt", [NSNumber numberWithLongLong:(long long)([[NSDate date] timeIntervalSinceDate:st])*1000]);
		setStat(stats, @"rst", @"Success");
		setStat(stats, @"code", [NSNumber numberWithInteger:response.statusCode]);
	} else {
		setStat(stats, @"rst", errorFromDesc([error localizedDescription]));
	}
	if (!error || ![[error localizedDescription] isEqualToString:@"cancelled"]) {
		[_statsManager addStatics:stats];
	}
}

- (void) recordBaseStats:(NSMutableDictionary *)stats
                 request:(NSMutableURLRequest *)request
                      st:(NSDate *)st {

	if (stats) {
		setStat(stats, @"path", request.URL.path);
		setStat(stats, @"net", [_statsManager getNetType]);
		setStat(stats, @"sip", [_statsManager getSIP]);
		setStat(stats, @"st",[NSNumber numberWithLongLong:(long long)([st timeIntervalSince1970]*1000000000)]);
		if (request.HTTPBody != nil) {
			setStat(stats, @"fs", [NSNumber numberWithInteger:[request.HTTPBody length]]);
		}
	}
}

- (void)     sendRequest2:(NSMutableURLRequest *)request
                withStats:(NSMutableDictionary *)stats
        withCompleteBlock:(QNCompleteBlock)completeBlock
        withProgressBlock:(QNInternalProgressBlock)progressBlock
          withCancelBlock:(QNCancelBlock)cancelBlock
              withIpArray:(NSArray*)ips
                withIndex:(int)index
               withDomain:(NSString *)domain
           withRetryTimes:(int)times
            withStartTime:(NSDate *)startTime {
	NSProgress *progress = nil;
	NSURL *url = request.URL;
	__block NSString *ip = nil;
	if(ips != nil) {
		ip = [ips objectAtIndex:(index%ips.count)];
		NSString *path = url.path;
		if (path == nil || [@"" isEqualToString:path]) {
			path = @"/";
		}
		url = buildUrl(ip, url.port, path);
		[request setValue:domain forHTTPHeaderField:@"Host"];

		setStat(stats, @"ip", ip);
	}

	NSDate *st = [NSDate date];
	[self recordBaseStats:stats request:request st:st];


	request.URL = url;

	[request setTimeoutInterval:_timeout];

	[request setValue:[[QNUserAgent sharedInstance] description] forHTTPHeaderField:@"User-Agent"];
	[request setValue:nil forHTTPHeaderField:@"Accept-Language"];

	if (stats && request.HTTPBody != nil) {
		setStat(stats, @"fs", [NSNumber numberWithInteger:[request.HTTPBody length]]);
	}

	if (progressBlock == nil) {
		progressBlock = ^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
		};
	}
	QNInternalProgressBlock progressBlock2 = ^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
		if (stats && totalBytesWritten == totalBytesExpectedToWrite) {
			double sendTime = [[NSDate date] timeIntervalSinceDate:st];
			setStat(stats, @"snt", [NSNumber numberWithLongLong:(long long)(sendTime * 1000)]);
		}
		if (stats && request.HTTPBodyStream) {
			setStat(stats, @"fs", [NSNumber numberWithLongLong:totalBytesWritten]);
		}
		progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
	};
	__block QNProgessDelegate *delegate = [[QNProgessDelegate alloc] initWithProgress:progressBlock2];

	NSURLSessionUploadTask *uploadTask = [_httpManager uploadTaskWithRequest:request fromData:nil progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
	                                              NSData *data = responseObject;
	                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	                                              double duration = [[NSDate date] timeIntervalSinceDate:startTime];
	                                              QNResponseInfo *info;
	                                              NSDictionary *resp = nil;
	                                              if (delegate.progress != nil) {
	                                                      [delegate.progress removeObserver:delegate forKeyPath:@"fractionCompleted" context:(__bridge void *)(delegate)];
	                                                      delegate.progress = nil;
						      }
	                                              if (_converter != nil && _noProxy && (index+1 < ips.count || times>0) && needRetry(httpResponse, error)) {
	                                                      [self sendRequest2:request withStats:nil withCompleteBlock:completeBlock withProgressBlock:progressBlock withCancelBlock:cancelBlock withIpArray:ips withIndex:index+1 withDomain:domain withRetryTimes:times -1 withStartTime:startTime];
	                                                      return;
						      }
	                                              if (error == nil) {
	                                                      info = [QNSessionManager buildResponseInfo:httpResponse withError:nil withDuration:duration withResponse:data withHost:domain withIp:ip];
	                                                      if (info.isOK) {
	                                                              NSError *tmp;
	                                                              resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&tmp];
							      }
						      }
	                                              else {
	                                                      info = [QNSessionManager buildResponseInfo:httpResponse withError:error withDuration:duration withResponse:data withHost:domain withIp:ip];
						      }

	                                              [self recordRst:stats response:httpResponse error:error st:st];

	                                              completeBlock(info, resp);
					      }];
	if (progress != nil) {
		[progress addObserver:delegate forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:(__bridge void *)delegate];
		delegate.progress = progress;
		delegate.task = uploadTask;
		delegate.cancelBlock = cancelBlock;
	}

	[uploadTask resume];
}

- (void)    multipartPost:(NSString *)url
                 withData:(NSData *)data
               withParams:(NSDictionary *)params
             withFileName:(NSString *)key
             withMimeType:(NSString *)mime
                withStats:(NSMutableDictionary *)stats
        withCompleteBlock:(QNCompleteBlock)completeBlock
        withProgressBlock:(QNInternalProgressBlock)progressBlock
          withCancelBlock:(QNCancelBlock)cancelBlock {
	NSMutableURLRequest *request = [_httpManager.requestSerializer
	                                multipartFormRequestWithMethod:@"POST"
	                                URLString:url
	                                parameters:params
	                                constructingBodyWithBlock: ^(id < AFMultipartFormData > formData) {
	                                        [formData appendPartWithFileData:data name:@"file" fileName:key mimeType:mime];
					}

	                                error:nil];
	[self sendRequest:request
	 withStats:stats
	 withCompleteBlock:completeBlock
	 withProgressBlock:progressBlock
	 withCancelBlock:cancelBlock];
}

- (void)             post:(NSString *)url
                 withData:(NSData *)data
               withParams:(NSDictionary *)params
              withHeaders:(NSDictionary *)headers
                withStats:(NSMutableDictionary *)stats
        withCompleteBlock:(QNCompleteBlock)completeBlock
        withProgressBlock:(QNInternalProgressBlock)progressBlock
          withCancelBlock:(QNCancelBlock)cancelBlock {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
	if (headers) {
		[request setAllHTTPHeaderFields:headers];
	}

	[request setHTTPMethod:@"POST"];

	if (params) {
		[request setValuesForKeysWithDictionary:params];
	}
	[request setHTTPBody:data];
	QNAsyncRun( ^{
		[self sendRequest:request
		 withStats:stats
		 withCompleteBlock:completeBlock
		 withProgressBlock:progressBlock
		 withCancelBlock:cancelBlock];
	});
}

@end

#endif
