//
//  Configure.m
//  MarkLite
//
//  Created by zhubch on 11/9/15.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "Configure.h"
#import "FileManager.h"

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
            if (conf.currentVerion.length == 0 || ![conf.currentVerion isEqualToString:kAppVersionNo]) {
                [conf upgrade];
            }
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
    [aCoder encodeObject:self.upgradeTime forKey:@"triedTime"];
    [aCoder encodeObject:self.currentVerion forKey:@"currentVerion"];
    [aCoder encodeObject:self.fontName forKey:@"fontName"];
    [aCoder encodeBool:self.keyboardAssist forKey:@"keyboardAssist"];
    [aCoder encodeBool:self.hasShownSwipeTips forKey:@"hasShownSwipeTips"];
    [aCoder encodeBool:self.landscapeEdit forKey:@"landscapeEdit"];
    [aCoder encodeBool:self.hasRated forKey:@"hasRated"];
    [aCoder encodeInteger:self.sortOption forKey:@"sortOption"];
    [aCoder encodeFloat:self.imageResolution forKey:@"imageResolution"];
    [aCoder encodeFloat:self.fontSize forKey:@"fontSize"];
    [aCoder encodeObject:self.defaultParent forKey:@"defaultParent"];
    [aCoder encodeInteger:self.useTimes forKey:@"useTimes"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        _highlightColor = [aDecoder decodeObjectForKey:@"highlightColor"];
        _style = [aDecoder decodeObjectForKey:@"style"];
        _themeColor = [aDecoder decodeObjectForKey:@"themeColor"];
        _upgradeTime = [aDecoder decodeObjectForKey:@"upgradeTime"];
        _fontName = [aDecoder decodeObjectForKey:@"fontName"];
        _keyboardAssist = [aDecoder decodeBoolForKey:@"keyboardAssist"];
        _landscapeEdit = [aDecoder decodeBoolForKey:@"landscapeEdit"];
        _hasRated = [aDecoder decodeBoolForKey:@"hasRated"];
        _hasShownSwipeTips = [aDecoder decodeBoolForKey:@"hasShownSwipeTips"];
        _sortOption = [aDecoder decodeIntegerForKey:@"sortOption"];
        _imageResolution = [aDecoder decodeFloatForKey:@"imageResolution"];
        _fontSize = [aDecoder decodeFloatForKey:@"fontSize"];
        _currentVerion = [aDecoder decodeObjectForKey:@"currentVerion"];
        _defaultParent = [aDecoder decodeObjectForKey:@"defaultParent"];
        _useTimes = [aDecoder decodeIntegerForKey:@"useTimes"];
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
    if (_fontName.length < 1) {
        _fontName = @"Hiragino Sans";
    }
    _keyboardAssist = YES;
    _imageResolution = 0.9;
    _upgradeTime = [NSDate date];
    _currentVerion = kAppVersionNo;
    _sortOption = 0;
    _landscapeEdit = NO;
    _hasRated = NO;
    _fontSize = 16;
    _useTimes = 0;
}

- (void)upgrade
{
//    _highlightColor = @{
//                        @"title":RGB(@"488FE1"),
//                        @"link":RGB(@"465DC6"),
//                        @"image":RGB(@"5245AE"),
//                        @"bold":RGB(@"000000"),
//                        @"quotes":RGB(@"AE8A86"),
//                        @"deletion":RGB(@"747270"),
//                        @"separate":RGB(@"BD1586"),
//                        @"list":RGB(@"49362E"),
//                        @"code":RGB(@"33A191"),
//                        };
    _upgradeTime = [NSDate date];
    _currentVerion = kAppVersionNo;
    if (_sortOption > 1) {
        _sortOption = 0;
    }
    _fontSize = 16;
    _landscapeEdit = NO;
    [[FileManager sharedManager] recover];
    _useTimes = 1;
}

@end
