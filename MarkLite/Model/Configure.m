//
//  Configure.m
//  MarkLite
//
//  Created by zhubch on 11/9/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "Configure.h"

#define RGB(x) [UIColor colorWithRGBString:x]
@implementation Configure
{
    NSInteger _iCloudState;
}

+ (instancetype)sharedConfigure
{
    static Configure *conf = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *path = [documentPath() stringByAppendingPathComponent:@"Configure.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            conf = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }else{
            conf = [[self alloc]init];
            [conf reset];
        }
    });
    return conf;
}

- (BOOL)saveToFile
{
    NSString *path = [documentPath() stringByAppendingPathComponent:@"Configure.plist"];
    
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.highlightColor forKey:@"highlightColor"];
    [aCoder encodeObject:self.style forKey:@"style"];
    [aCoder encodeObject:self.themeColor forKey:@"themeColor"];
    [aCoder encodeObject:self.triedTime forKey:@"triedTime"];
    [aCoder encodeObject:self.fontName forKey:@"fontName"];
    [aCoder encodeBool:self.keyboardAssist forKey:@"keyboardAssist"];
    [aCoder encodeInteger:self.iCloudState forKey:@"iCloudState"];
    [aCoder encodeFloat:self.imageResolution forKey:@"imageResolution"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.highlightColor = [aDecoder decodeObjectForKey:@"highlightColor"];
        self.style = [aDecoder decodeObjectForKey:@"style"];
        self.themeColor = [aDecoder decodeObjectForKey:@"themeColor"];
        self.triedTime = [aDecoder decodeObjectForKey:@"triedTime"];
        self.fontName = [aDecoder decodeObjectForKey:@"fontName"];
        self.keyboardAssist = [aDecoder decodeBoolForKey:@"keyboardAssist"];
        self.iCloudState = [aDecoder decodeIntegerForKey:@"iCloudState"];
        self.imageResolution = [aDecoder decodeFloatForKey:@"imageResolution"];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)reset
{    
    _highlightColor = @{
                        @"title":RGB(@"488FE1"),
                        @"link":RGB(@"465DC6"),
                        @"image":RGB(@"5245AE"),
                        @"bold":RGB(@"000000"),
                        @"quotes":RGB(@"AE8A86"),
                        @"deletion":RGB(@"747270"),
                        @"separate":RGB(@"BD1586"),
                        @"list":RGB(@"49362E"),
                        @"code":RGB(@"33A191"),
                        };
    _style = @"GitHub2";
    _fontName = @"Hiragino Sans";
    _keyboardAssist = YES;
    _imageResolution = 0.5;
    _iCloudState = 3;
}

- (void)setICloudState:(NSInteger)iCloudState
{
    _iCloudState = iCloudState;
    if (iCloudState == 2) {
        _triedTime = [NSDate date];
    }
    [self saveToFile];
}

- (NSInteger)iCloudState
{
    if (_iCloudState != 2) {
        return _iCloudState;
    }
    if ([[NSDate date] timeIntervalSinceDate:_triedTime] > 30) {
        _iCloudState = 1;
    }
    return _iCloudState;
}

@end
