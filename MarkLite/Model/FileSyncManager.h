//
//  FileSyncManager.h
//  MarkLite
//
//  Created by zhubch on 11/26/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;
@interface FileSyncManager : NSObject

+ (instancetype)sharedManager;

- (void)uploadFile:(Item *)item progressHandler:(void(^)(float percent))handler result:(void(^)(BOOL success))result;

- (void)downloadFile:(NSString*)key progressHandler:(void(^)(float percent))handler result:(void(^)(BOOL success, NSData *data))result;
;

- (void)rootFromServer:(void(^)(Item *root))callBack;

- (void)update:(void(^)(BOOL success))callBack;

- (void)stop;

@end
