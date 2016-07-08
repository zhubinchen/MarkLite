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

@property (nonatomic,assign) NSInteger iCloudState; //0 未开通 1 试用过 2 试用中 3已开通

@property (nonatomic,strong) NSDate *triedTime;

@property (nonatomic,assign) NSInteger leftImages;

@property (nonatomic,assign) CGFloat imageResolution;

+ (instancetype)sharedConfigure;

- (BOOL)saveToFile;

@end
