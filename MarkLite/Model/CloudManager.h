//
//  CloudManager.h
//  MarkLite
//
//  Created by zhubch on 6/23/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface CloudManager : NSObject

+ (instancetype) sharedManager;

- (instancetype)init;

- (void)uploadFile:(NSString*)path;

- (BOOL)downloadFile:(NSString*)path;

@end
