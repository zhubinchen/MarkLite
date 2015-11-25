//
//  User.m
//  MarkLite
//
//  Created by zhubch on 11/25/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "User.h"

@implementation User

+ (instancetype)currentUser
{
    static User *user = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSString documentPath] stringByAppendingPathComponent:@"user.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            user = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }else{
            user = [[self alloc]init];
        }
    });
    return user;
}

- (BOOL)archive
{
    NSString *path = [[NSString documentPath] stringByAppendingPathComponent:@"user.plist"];
    
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.account forKey:@"account"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeBool:self.hasLogin forKey:@"hasLogin"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.account=[aDecoder decodeObjectForKey:@"account"];
        self.password=[aDecoder decodeObjectForKey:@"password"];
        self.name=[aDecoder decodeObjectForKey:@"name"];
        self.userId=[aDecoder decodeObjectForKey:@"userId"];
        self.hasLogin=[aDecoder decodeBoolForKey:@"hasLogin"];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
