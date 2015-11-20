//
//  BmobGeoPoint.h
//  BmobSDK
//
//  Created by Bmob on 13-8-6.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface BmobGeoPoint : NSObject


/// 纬度，有效范围 (-90.0, 90.0)
@property(nonatomic)double latitude;

/// 经度，有效范围 (-180.0, 180.0).
@property(nonatomic)double longitude;


/**
 *	初始化BmobGeoPoint
 *
 *  @param	mylongitude	经度
 *	@param	mylatitude	纬度
 *
 *	@return	返回BmobGeoPoint对象
 */
-(id)initWithLongitude:(double)mylongitude   WithLatitude:(double)mylatitude;


/**
 *	设置经纬度
 *
 *	@param	mylongitude	经度
 *  @param	mylatitude	纬度
 */
-(void)setLongitude:(double)mylongitude Latitude:(double)mylatitude ;



@end
