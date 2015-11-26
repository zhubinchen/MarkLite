//
//  QNConfiguration.m
//  QiniuSDK
//
//  Created by bailong on 15/5/21.
//  Copyright (c) 2015年 Qiniu. All rights reserved.
//

#import "QNConfiguration.h"
#import "QNNetworkInfo.h"
#import "HappyDNS.h"

#import "QNSystem.h"

const UInt32 kQNBlockSize = 4 * 1024 * 1024;

static void addServiceToDns(QNServiceAddress* address, QNDnsManager *dns) {
	NSArray *ips = address.ips;
	if (ips == nil) {
		return;
	}
	NSURL *u = [[NSURL alloc] initWithString:address.address];
	NSString *host = u.host;
	for (int i = 0; i<ips.count; i++) {
		[dns putHosts:host ip:ips[i]];
	}
}

static void addZoneToDns(QNZone *zone, QNDnsManager* dns){
	if (zone.up != nil) {
		addServiceToDns(zone.up, dns);
	}
	if (zone.upBackup != nil) {
		addServiceToDns(zone.upBackup, dns);
	}
}

static QNDnsManager* initDns(QNConfigurationBuilder *builder) {
	QNDnsManager *d = builder.dns;
	if (d == nil) {
		id<QNResolverDelegate> r1 = [QNResolver systemResolver];
		id<QNResolverDelegate> r2 = [[QNResolver alloc] initWithAddres:@"119.29.29.29"];
		id<QNResolverDelegate> r3 = [[QNResolver alloc] initWithAddres:@"114.114.115.115"];
		d = [[QNDnsManager alloc] init:[NSArray arrayWithObjects:r1,r2, r3, nil] networkInfo:[QNNetworkInfo normal ]];
	}
	return d;
}

@implementation QNConfiguration

+ (instancetype)build:(QNConfigurationBuilderBlock)block {
	QNConfigurationBuilder *builder = [[QNConfigurationBuilder alloc] init];
	block(builder);
	return [[QNConfiguration alloc] initWithBuilder:builder];
}

- (instancetype)initWithBuilder:(QNConfigurationBuilder *)builder {
	if (self = [super init]) {
		_up = builder.zone.up;
		_upBackup = builder.zone.upBackup == nil ? builder.zone.up : builder.zone.upBackup;

		_chunkSize = builder.chunkSize;
		_putThreshold = builder.putThreshold;
		_retryMax = builder.retryMax;
		_timeoutInterval = builder.timeoutInterval;

		_recorder = builder.recorder;
		_recorderKeyGen = builder.recorderKeyGen;

		_proxy = builder.proxy;

		_converter = builder.converter;

		_upStatsDropRate = 1 - builder.upStatsRate;
		if (_upStatsDropRate > 1) {
			_upStatsDropRate = 1;
		}
		if (_upStatsDropRate < 0) {
			_upStatsDropRate = 0;
		}

		_disableATS = builder.disableATS;
		if (_disableATS || !hasAts()) {
			_dns = initDns(builder);
			addZoneToDns(builder.zone, _dns);
		}else{
			_dns = nil;
		}
	}
	return self;
}

@end

@implementation QNConfigurationBuilder

- (instancetype)init {
	if (self = [super init]) {
		_zone = [QNZone zone0];
		_chunkSize = 256 * 1024;
		_putThreshold = 512 * 1024;
		_retryMax = 2;
		_timeoutInterval = 60;

		_recorder = nil;
		_recorderKeyGen = nil;

		_proxy = nil;
		_converter = nil;

		_disableATS = YES;
        
        _upStatsRate = 0.3;
	}
	return self;
}

@end

@implementation QNServiceAddress : NSObject

- (instancetype) init:(NSString*)address ips:(NSArray*)ips {
	if (self = [super init]) {
		_address = address;
		_ips = ips;

	}
	return self;
}

@end

@implementation QNZone

- (instancetype)initWithUp:(QNServiceAddress *)up
                  upBackup:(QNServiceAddress *)upBackup {
	if (self = [super init]) {
		_up = up;
		_upBackup = upBackup;
	}

	return self;
}

+ (instancetype)createWithHost:(NSString*)up backupHost:(NSString*)backup ip1:(NSString*)ip1 ip2:(NSString*)ip2 {
	NSArray* ips = [NSArray arrayWithObjects:ip1,ip2, nil];
	NSString* a = [NSString stringWithFormat:@"http://%@", up];
	QNServiceAddress *s1 = [[QNServiceAddress alloc] init:a ips:ips];
	NSString* b = [NSString stringWithFormat:@"http://%@", backup];
	QNServiceAddress *s2 = [[QNServiceAddress alloc] init:b ips:ips];
	return [[QNZone alloc] initWithUp:s1 upBackup:s2];
}

+ (instancetype)zone0 {
	static QNZone *z0 = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		z0 = [QNZone createWithHost:@"upload.qiniu.com" backupHost:@"up.qiniu.com" ip1:@"183.136.139.10" ip2:@"115.231.182.136"];
	});
	return z0;
}

+ (instancetype)zone1 {
	static QNZone *z1 = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		z1 = [QNZone createWithHost:@"upload-z1.qiniu.com" backupHost:@"up-z1.qiniu.com" ip1:@"106.38.227.28" ip2:@"106.38.227.27"];
	});
	return z1;
}

@end
