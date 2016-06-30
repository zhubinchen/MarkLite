//
//  Configure.h
//  MarkLite
//
//  Created by zhubch on 11/9/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configure : NSObject <NSCoding>

@property (nonatomic,strong) NSString *style;

@property (nonatomic,strong) NSString *themeColor;

@property (nonatomic,strong) NSString *fontName;

@property (nonatomic,strong) NSDictionary *highlightColor;

@property (nonatomic,assign) BOOL keyboardAssist;

@property (nonatomic,assign) BOOL cloud;

@property (nonatomic,assign) BOOL hasStared;

@property (nonatomic,assign) BOOL imageServer;

@property (nonatomic,assign) NSInteger leftDays;

@property (nonatomic,assign) CGFloat compressionQuality;

+ (instancetype)sharedConfigure;

- (BOOL)saveToFile;

@end
