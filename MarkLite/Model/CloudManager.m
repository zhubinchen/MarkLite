
//
//  CloudManager.m
//  MarkLite
//
//  Created by zhubch on 6/23/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "CloudManager.h"

#define UBIQUITY_CONTAINER_URL @"iCloud.com.zhubch.MarkLite"

@implementation CloudManager
{
    NSURL *ubiquityURL;
}

+ (instancetype)sharedManager
{
    static CloudManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[CloudManager alloc]init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        NSURL* url = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_URL];
        if (!url) {
            return nil;
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        ubiquityURL = [[fm URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
        NSLog(@"iCloud path = %@", [ubiquityURL path]);
        if ([fm fileExistsAtPath:[ubiquityURL path]] == NO)
        {
            NSLog(@"iCloud Documents directory does not exist");
            [fm createDirectoryAtURL:ubiquityURL withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
            NSLog(@"iCloud Documents directory exists");
        }
        
    }
    
    return self;
}

- (void)uploadFile:(NSString *)path
{
//    NSURL *localUrl = [NSURL fileURLWithPath:path];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSString *relativePath = [self relativePathOfPath:path];
//    NSURL *remoteUrl = [ubiquityURL URLByAppendingPathComponent:relativePath];
//    NSError *error = nil;
//    [fm copyItemAtURL:localUrl toURL:remoteUrl error:&error];
//    NSLog(@"%@",error);
}

- (BOOL)downloadFile:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    return YES;
//    NSError *error = nil;
//    [fm copyItemAtURL:localUrl toURL:remoteUrl error:&error];
}

- (NSString*)relativePathOfPath:(NSString*)path{
    return [path stringByReplacingOccurrencesOfString:documentPath() withString:@""];
}

@end
