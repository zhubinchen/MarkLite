//
//  BmobGPSSwitch.h
//  BmobSDK
//
//  Created by Bmob on 14-5-13.
//  Copyright (c) 2014年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BmobGPSSwitch : NSObject

/**
 *  是否打开GPS
 *
 *  @param turnOn 是否打开GPS
 */
+(void)gpsSwitch:(BOOL)turnOn;

@end
