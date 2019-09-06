//
//  MPAsset.h
//  MacDown
//
//  Created by Tzu-ping Chung  on 29/6.
//  Copyright (c) 2014 Tzu-ping Chung . All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, MPAssetOption)
{
    MPAssetNone,
    MPAssetEmbedded,
    MPAssetFullLink,
};

@interface MPAsset : NSObject
+ (instancetype)assetWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;
- (NSString *)htmlForOption:(MPAssetOption)option;
@end


@interface MPStyleSheet : MPAsset
+ (instancetype)CSSWithURL:(NSURL *)url;
@end


@interface MPScript : MPAsset
+ (instancetype)javaScriptWithURL:(NSURL *)url;
@end


@interface MPEmbeddedScript : MPScript
@end
