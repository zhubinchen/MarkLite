//
//  QNHttpManager.m
//  QiniuSDK
//
//  Created by bailong on 14/10/1.
//  Copyright (c) 2014年 Qiniu. All rights reserved.
//

#import "AFNetworking.h"

#import "QNConfiguration.h"
#import "QNHttpManager.h"
#import "QNUserAgent.h"
#import "QNResponseInfo.h"
#import "QNDns.h"
#import "HappyDNS.h"
#import "QNStats.h"

@interface QNHttpManager ()
@property (nonatomic) AFHTTPRequestOperationManager *httpManager;
@property UInt32 timeout;
@property (nonatomic, strong) QNUrlConvert converter;
@property (nonatomic) QNDnsManager *dns;
@property (nonatomic) QNStats *statsManager;
@end

const int kQNRetryConnectTimes = 3;

static NSURL *buildUrl(NSString *host, NSNumber *port, NSString *path){
	port = port == nil ?[NSNumber numberWithInt:80] : port;
	NSString *p = [[NSString alloc] initWithFormat:@"http://%@:%@%@", host, port, path];
	return [[NSURL alloc] initWithString:p];
}

static BOOL needRetry(AFHTTPRequestOperation *op, NSError *error){
	if (error != nil) {
		return error.code < -1000;
	}
	if (op == nil) {
		return YES;
	}
	int status = (int)[op.response statusCode];
	return status >= 500 && status < 600 && status != 579;
}

@implementation QNHttpManager

- (instancetype)initWithTimeout:(UInt32)timeout
                   urlConverter:(QNUrlConvert)converter
                upStatsDropRate:(float)dropRate
                            dns:(QNDnsManager *)dns {
	if (self = [super init]) {
		_httpManager = [[AFHTTPRequestOperationManager alloc] init];
		_httpManager.responseSerializer = [AFJSONResponseSerializer serializer];
		_timeout = timeout;
		_converter = converter;
		_dns = dns;
		_statsManager = [[QNStats alloc] initWithPushInterval:0 dropRate:dropRate statsHost:nil dns:dns];
	}

	return self;
}

- (instancetype)init {
	return [self initWithTimeout:60 urlConverter:nil upStatsDropRate:-1 dns:nil];
}

+ (QNResponseInfo *)buildResponseInfo:(AFHTTPRequestOperation *)operation
                            withError:(NSError *)error
                         withDuration:(double)duration
                         withResponse:(id)responseObject
                               withIp:(NSString *)ip {
	QNResponseInfo *info;
	NSString *host = operation.request.URL.host;

	if (operation.response) {
		int status =  (int)[operation.response statusCode];
		NSDictionary *headers = [operation.response allHeaderFields];
		NSString *reqId = headers[@"X-Reqid"];
		NSString *xlog = headers[@"X-Log"];
		NSString *xvia = headers[@"X-Via"];
		if (xvia == nil) {
			xvia = headers[@"X-Px"];
		}
		info = [[QNResponseInfo alloc] init:status withReqId:reqId withXLog:xlog withXVia:xvia withHost:host withIp:ip withDuration:duration withBody:responseObject];
	}
	else {
		info = [QNResponseInfo responseInfoWithNetError:error host:host duration:duration];
	}
	return info;
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


	AFHTTPRequestOperation *operation = [_httpManager
	                                     HTTPRequestOperationWithRequest:request
	                                     success: ^(AFHTTPRequestOperation *operation, id responseObject) {
	                                             double duration = [[NSDate date] timeIntervalSinceDate:startTime];
	                                             QNResponseInfo *info = [QNHttpManager buildResponseInfo:operation withError:nil withDuration:duration withResponse:operation.responseData withIp:ip];
	                                             NSDictionary *resp = nil;
	                                             if (info.isOK) {
	                                                     resp = responseObject;
						     }
	                                             [self recordRst:stats response:operation.response error:nil st:st];
	                                             completeBlock(info, resp);
					     }                                                                failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
	                                             [self recordRst:stats response:operation.response error:error st:st];
	                                             if (_converter != nil && (index+1 < ips.count || times>0) && needRetry(operation, error)) {

	                                                     NSLog(@"idx: %d, count: %lu", index, (unsigned long)ips.count);
	                                                     int nindex = index;
	                                                     if (ips.count != 0)
								     nindex = (index + 1) % ips.count;

	                                                     [self sendRequest2:request withStats:nil withCompleteBlock:completeBlock withProgressBlock:progressBlock withCancelBlock:cancelBlock withIpArray:ips withIndex:nindex withDomain:domain withRetryTimes:times -1 withStartTime:startTime];
	                                                     return;
						     }
	                                             double duration = [[NSDate date] timeIntervalSinceDate:startTime];
	                                             QNResponseInfo *info = [QNHttpManager buildResponseInfo:operation withError:error withDuration:duration withResponse:operation.responseData withIp:ip];
	                                             NSLog(@"failure %@", info);
	                                             completeBlock(info, nil);
					     }
	                                    ];

	__block AFHTTPRequestOperation *op = nil;
	if (cancelBlock) {
		op = operation;
	}

	[operation setUploadProgressBlock: ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
	         if (stats && totalBytesWritten == totalBytesExpectedToWrite) {
	                 double sendTime = [[NSDate date] timeIntervalSinceDate:st];
	                 setStat(stats, @"snt", [NSNumber numberWithLongLong:(long long)(sendTime * 1000)]);
		 }
	         if (stats && request.HTTPBodyStream) {
	                 setStat(stats, @"fs", [NSNumber numberWithLongLong:totalBytesWritten]);
		 }
	         if (progressBlock) {
	                 progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
		 }
	         if (cancelBlock) {
	                 if (cancelBlock()) {
	                         [op cancel];
			 }
	                 op = nil;
		 }
	 }];

	[_httpManager.operationQueue addOperation:operation];
}

- (void)      sendRequest:(NSMutableURLRequest *)request
                withStats:(NSMutableDictionary *)stats
        withCompleteBlock:(QNCompleteBlock)completeBlock
        withProgressBlock:(QNInternalProgressBlock)progressBlock
          withCancelBlock:(QNCancelBlock)cancelBlock {
	NSString *u = request.URL.absoluteString;
	NSURL *url = request.URL;
	NSString *domain =url.host;
	NSArray * ips = nil;
	NSDate *startTime = [NSDate date];


	setStat(stats, @"domain", domain);

	if (_converter != nil) {
		url = [[NSURL alloc] initWithString:_converter(u)];
		request.URL = url;
		domain = url.host;
	}else if(_dns != nil && [url.scheme isEqual: @"http"]) {
		ips = [_dns queryWithDomain:[[QNDomain alloc] init:domain hostsFirst:NO hasCname:YES maxTtl:1000]];
		double duration = [[NSDate date] timeIntervalSinceDate:startTime];
		setStat(stats, @"dt", [NSNumber numberWithInt:(int)(duration*1000)]);
		if (ips == nil || ips.count == 0) {
			NSError *error = [[NSError alloc] initWithDomain:domain code:-1003 userInfo:@{ @"error":@"unkonwn host" }];
			QNResponseInfo *info = [QNResponseInfo responseInfoWithNetError:error host:domain duration:duration];
			NSLog(@"failure %@", info);

			setStat(stats, @"rst", @"ErrDomainNotFound");

			//  这是dns的开始时间，用于假如dns查询失败的时候计算出pi
			setStat(stats, @"st", [NSNumber numberWithLongLong:(long long)([startTime timeIntervalSinceReferenceDate]*100000000)]);
			[_statsManager addStatics: stats];
			completeBlock(info, nil);
			return;
		}
	}
	[self sendRequest2:request withStats:stats withCompleteBlock:completeBlock withProgressBlock:progressBlock withCancelBlock:cancelBlock withIpArray:ips withIndex:0 withDomain:domain withRetryTimes:kQNRetryConnectTimes withStartTime:startTime];
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
	[self sendRequest:request
	 withStats:stats
	 withCompleteBlock:completeBlock
	 withProgressBlock:progressBlock
	 withCancelBlock:cancelBlock];
}

@end
