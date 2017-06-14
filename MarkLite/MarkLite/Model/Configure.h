//
//  Configure.h
//  MarkLite
//
//  Created by Bingcheng on 11/9/15.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface Configure : NSObject <NSCoding>

@property (nonatomic,strong) NSString *style;

@property (nonatomic,strong) NSString *highlightStyle;

@property (nonatomic,strong) NSString *fontName;

@property (nonatomic,assign) CGFloat   fontSize;

@property (nonatomic,strong) NSDictionary *highlightColor;

@property (nonatomic,assign) NSInteger sortOption;

@property (nonatomic,assign) BOOL keyboardAssist;

@property (nonatomic,assign) BOOL useLocalImage;

@property (nonatomic,assign) BOOL landscapeEdit;

@property (nonatomic,strong) NSDate *upgradeTime;

@property (nonatomic,strong) NSDate *showRateTime;

@property (nonatomic,assign) BOOL hasRated;

@property (nonatomic,assign) CGFloat imageResolution;

@property (nonatomic,strong) NSString *currentVerion;

@property (nonatomic,assign) BOOL hasShownSwipeTips;

@property (nonatomic,assign) NSInteger useTimes;

@property (nonatomic,strong) Item *currentItem;

+ (instancetype)sharedConfigure;

- (BOOL)saveToFile;

@end
