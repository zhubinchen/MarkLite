//
//  QNStats.m
//  QiniuSDK
//
//  Created by ltz on 9/21/15.
//  Copyright (c) 2015 Qiniu. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "QNReachability.h"
#endif

//#import "GZIP.h"
#import "QNStats.h"
#import "AFNetworking.h"
#import "HappyDns.h"

void setStat(NSMutableDictionary *dic, id key, id value) {
	if (value == nil || dic == nil) {
		return;
	}
	[dic setObject:value forKey:key];
}

NSString *errorFromDesc(NSString *desc) {
	if ([desc isEqualToString:@"Could not connect to the server."]) {
		return @"ErrConnectFailed";
	}
	if ([desc isEqualToString:@"The network connection was lost."]) {
		return @"ErrBrokenConnection";
	}
	if ([desc isEqualToString:@"A server with the specified hostname could not be found."]) {
		return @"ErrDomainNotFound";
	}
	if ([desc isEqualToString:@"The request timed out."]) {
		return @"ErrTimeout";
	}
	NSLog(@"unknown: %@", desc);
	return @"ErrUnknown";
}

@interface QNStats ()

@property (nonatomic) AFHTTPRequestOperationManager *httpManager;
@property (nonatomic) NSMutableArray *statsBuffer;
@property (nonatomic) NSLock *bufLock;


@property (nonatomic,retain) NSTimer *getIPTimer;


// ...
@property (atomic) NSString *radioAccessTechnology;
@property int pushDropRate;
@property (nonatomic) NSString *phoneModel; // dev
@property (nonatomic) NSString *systemName; // os
@property (nonatomic) NSString *systemVersion; // sysv
@property (nonatomic) NSString *appName;  // app
@property (nonatomic) NSString *appVersion; // appv

@end

QNStats *defaultStatsManager = nil;

@implementation QNStats

- (instancetype) init {

	return [self initWithPushInterval:-1 dropRate:-1 statsHost:nil dns:nil];
}

- (instancetype) initWithPushInterval: (int) interval
                             dropRate: (float) dropRate
                            statsHost:(NSString *) statsHost
                                  dns:(QNDnsManager *) dns {

	self = [super init];

	if (interval <= 0) {
		interval = 180;
	}
	if (dropRate < 0) {
		dropRate = 0.7;
	}
	if (!statsHost) {
		//statsHost = @"http://192.168.210.97:2334"; // office
		//statsHost = @"http://192.168.199.202:2334"; // home
		statsHost = @"http://reportqos.qiniuapi.com";
	}
	if (!dns) {
		id<QNResolverDelegate> r1 = [QNResolver systemResolver];
		id<QNResolverDelegate> r2 = [[QNResolver alloc] initWithAddres:@"223.6.6.6"];
		id<QNResolverDelegate> r3 = [[QNResolver alloc] initWithAddres:@"114.114.115.115"];
		dns = [[QNDnsManager alloc] init:[NSArray arrayWithObjects:r1,r2, r3, nil] networkInfo:[QNNetworkInfo normal ]];
	}

	_pushInterval = interval;
	_statsHost = statsHost;
	_dns = dns;

	_pushDropRate = (int)(100*dropRate);

	_statsBuffer = [[NSMutableArray alloc] init];
	_bufLock = [[NSLock alloc] init];

	_httpManager = [[AFHTTPRequestOperationManager alloc] init];
	_httpManager.responseSerializer = [AFJSONResponseSerializer serializer];

	_count = 0;

	// get out ip first time
	[self getOutIp];

#if TARGET_OS_IPHONE

	// radio access technology
	_telephonyInfo = [CTTelephonyNetworkInfo new];
	_radioAccessTechnology = _telephonyInfo.currentRadioAccessTechnology;

	//NSLog(@"Current Radio Access Technology: %@", _radioAccessTechnology);
	[NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
	 object:nil
	 queue:nil
	 usingBlock:^(NSNotification *note) {
	         _radioAccessTechnology = _telephonyInfo.currentRadioAccessTechnology;
	         //NSLog(@"New Radio Access Technology: %@", _telephonyInfo.currentRadioAccessTechnology);
	         [self getOutIp];
	 }];

	// WiFi, WLAN, or nothing
	_wifiReach = [QNReachability reachabilityForInternetConnection];
	_reachabilityStatus = _wifiReach.currentReachabilityStatus;

	[NSNotificationCenter.defaultCenter addObserverForName:kQNReachabilityChangedNotification
	 object:nil
	 queue:nil
	 usingBlock:^(NSNotification *note) {
	         _reachabilityStatus = _wifiReach.currentReachabilityStatus;

	         if (_reachabilityStatus != QNNotReachable) {
	                 [self getOutIp];
		 }
	 }];
	[_wifiReach startNotifier];

	// init device information
	_phoneModel = [[UIDevice currentDevice] model];
	_systemName = [[UIDevice currentDevice] systemName];
	_systemVersion = [[UIDevice currentDevice] systemVersion];
#elif TARGET_OS_OSX
	_phoneModel = @""
	              _systemName = @"osx"
	                            _systemVersion = @"";
#else
	_phoneModel = @"";
	_systemName = @"";
	_systemVersion = @"";
#endif

	// timer for push
//	NSLog(@"interval %d", _pushInterval);
	_pushTimer = [NSTimer scheduledTimerWithTimeInterval:_pushInterval target:self selector:@selector(pushStats) userInfo:nil repeats:YES];
	[_pushTimer fire];

	_getIPTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(getOutIp) userInfo:nil repeats:YES];
	[_getIPTimer fire];



	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	_appName = [info objectForKey:@"CFBundleDisplayName"];
	NSString *majorVersion = [info objectForKey:@"CFBundleShortVersionString"];
	NSString *minorVersion = [info objectForKey:@"CFBundleVersion"];
	_appVersion = [NSString stringWithFormat:@"%@(%@)", majorVersion, minorVersion];

	if (_appName == nil) {
		_appName = @"";
	}
	if (_appVersion == nil) {
		_appVersion = @"";
	}

	return self;
}

- (void) addStatics:(NSMutableDictionary *)stat {

	if (!stat) {
		NSLog(@"stat nil");
		return;
	}
	[_bufLock lock];
	[_statsBuffer addObject:stat];
	[_bufLock unlock];
}

- (BOOL) shouldDrop {
	int r = arc4random_uniform(100);
	return r < _pushDropRate;
}

- (void) pushStats {

	@synchronized(self) {

#if TARGET_OS_IPHONE
		if (_reachabilityStatus == QNNotReachable) {
			return;
		}
#endif

		[_bufLock lock];
		if ([_statsBuffer count] == 0) {
			[_bufLock unlock];
			return;
		}
		NSMutableArray *reqs = [[NSMutableArray alloc] init];
		for (int i=0; i<[_statsBuffer count]; i++) {
			if ([self shouldDrop]) {
				continue;
			}
			[reqs addObject:[_statsBuffer objectAtIndex:i]];
		}
		//NSMutableArray *reqs = [[NSMutableArray alloc] initWithArray:_statsBuffer copyItems:YES];
		[_statsBuffer removeAllObjects];
		[_bufLock unlock];

		if ([reqs count]) {
			long long now = (long long)([[NSDate date] timeIntervalSince1970]* 1000000000);
			for (int i=0; i<[reqs count]; i++) {
				NSMutableDictionary *stat = [[reqs objectAtIndex:i] mutableCopy];
				long long st = [[stat valueForKey:@"st"] longLongValue];
				NSNumber *pi = [NSNumber numberWithLongLong:(now - st)];
				[stat setObject:pi forKey:@"pi"];
				[reqs setObject:stat atIndexedSubscript:i];
			}
			NSDictionary *parameters = @{@"dev": _phoneModel, @"os": _systemName, @"sysv": _systemVersion,
				                     @"app": _appName, @"appv": _appVersion,
				                     @"stats": reqs, @"v": @"0.1"};
			//NSLog(@"stats: %@", reqs);
			NSURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:[_statsHost stringByAppendingString:@"/v1/upstats"] parameters:parameters error:nil];
			//NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:nil];
			//NSLog(@"data::: %@", [NSString stringWithUTF8String:[data bytes]]);
			//data = [data gzippedDataWithCompressionLevel:0.7];
			//NSMutableURLRequest *req = [[NSMutableURLRequest alloc] init];

			//[req setHTTPMethod:@"POST"];
			//[req setURL:[NSURL URLWithString:[_statsHost stringByAppendingString:@"/v1/upstats"]]];
			//[req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			//[req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
			//[req setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
			//[req setHTTPBody:data];

			AFHTTPRequestOperation *operation = [_httpManager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
			                                             _count += [reqs count];

							     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			                                             NSLog(@"post stats failed, %@", error);
							     }];
			[_httpManager.operationQueue addOperation:operation];
		}
	}
}

- (void) getOutIp {

	[_httpManager GET:[_statsHost stringByAppendingString:@"/v1/ip"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
	         NSDictionary *rst = (NSDictionary *)responseObject;
	         _sip = [rst valueForKey:@"ip"];
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	         NSLog(@"get ip failed: %@", error);
	 }];
}

- (NSString *) getSIP {

	return _sip;
}

- (NSString *) getNetType {
#if TARGET_OS_IPHONE
	if (_reachabilityStatus == QNReachableViaWiFi) {
		return @"wifi";
	} else if (_reachabilityStatus == QNReachableViaWWAN) {
		return @"wan";
	}
#elif TARGET_OS_MAC
	return @"wifi";
#endif

	return @"";
}

@end

