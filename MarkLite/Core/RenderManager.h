//
//  RenderManager.h
//  MarkLite
//
//  Created by zhubch on 2017/7/3.
//  Copyright © 2017年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RenderManager : NSObject

@property (nonatomic,copy) NSString *markdownStyle;

@property (nonatomic,copy) NSString *highlightStyle;

+ (instancetype)defaultManager;

- (NSString*)render:(NSString*)string;

@end
