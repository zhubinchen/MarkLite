//
//  Utils.h
//  GolfPKiOS
//
//  Created by zhubch on 15/7/28.
//  Copyright (c) 2015年 Robusoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

#define kIsSimulator [[UIDevice currentDevice].model hasSuffix:@"Simulator"]

#define kIsPhone ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)

#define SYSTEM_VERSION   [[UIDevice currentDevice].systemVersion floatValue]


/**
 *  创建目录，存在就不创建
 */
static inline BOOL createDirectory(NSString *path){
    BOOL isDir = NO;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir ==YES && existed ==YES)) {
        return [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return YES;
}

static inline NSString* voicePath(NSString *name){
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *voiceDirPath = [docPath stringByAppendingPathComponent:@"voice"];
    return [voiceDirPath stringByAppendingPathComponent:name];
}

static inline NSString* imagePath(NSString *name){
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *imageDirPath = [docPath stringByAppendingPathComponent:@"image"];
    return [imageDirPath stringByAppendingPathComponent:name];
}

@interface NSObject (Utils)

@end

/**
 *  方便调试
 */
@interface NSData (Utils)

- (NSDictionary*)toDictionay;

- (NSString*)toString;

@end

@interface NSString (Utils)

/**
 *  判断手机号码格式合法
 */
@property (nonatomic,readonly) BOOL isValidPhone;

@property (nonatomic,readonly) BOOL isValidPassword;

@property (nonatomic,readonly) BOOL isValidZipCode;

@property (nonatomic,readonly) NSString *md5Hash;

@property (nonatomic,readonly) NSString *urlEncodeString;

- (NSAttributedString*)stringWithMiddleLine;

/**
 *  生成唯一的字符串
 */
+ (instancetype)uniqueString;

/**
 *  数据库字段名转成属性名
 */
- (NSString*)convertFromUpCase;

/**
 *  属性名转数据库字段名
 */
- (NSString*)convertFromLowCase;

/**
 *  获取显示这个字符串所需size
 *
 *  @param font    显示的字体
 *  @param maxSize 允许最大size
 *
 *  @return 所需size
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

/**
 *  @author zhipeng, 15-09-16 22:09:53
 *
 *  是否是int
 *
 *  @param string <#string description#>
 *
 *  @return <#return value description#>
 */
- (BOOL)isPureInt;

/**
 *  当前时间
 */
+ (NSString*)stringWithCurrentTime;

/**
 *  document目录
 */
+ (NSString*)documentPath;

@end

@interface NSDate (Utils)

/**
 *  时间戳
 */
@property (nonatomic,readonly) NSString *absluteTime;

/**
 *  格式化的时间 yyyy-MM-dd HH:mm:ss
 */
@property (nonatomic,readonly) NSString *formatDate;

/**
 *  截取日期部分
 */
@property (nonatomic,readonly) NSString *date;

/**
 *  截取时间部分
 */
@property (nonatomic,readonly) NSString *time;

/**
 *  用字符串初始化日期
 */
+ (instancetype)dateWithString:(NSString*)str;

+ (NSString*)formatWithAbsluteTime:(NSString*)absTime;

@end

@interface UIView (Utils)

/**
 *  view的截图
 */
@property (nonatomic,strong,readonly) UIImage *snap;
/**
 *  边框颜色，支持可视化修改
 */
@property (nonatomic,strong) IBInspectable UIColor *borderColor;
/**
 *  边框宽度，支持可视化修改
 */
@property (nonatomic,assign) IBInspectable CGFloat borderWidth;
/**
 *  边框半径。支持可视化修改
 */
@property (nonatomic,assign) IBInspectable CGFloat borderRadius;

//@property (nonatomic,strong) IBInspectable NSString *backgroundRGB;

- (UIImage*)snapInRect:(CGRect)rect;

/**
 *  设置成圆角
 *
 *  @param radius 圆角半径
 */
- (void)makeRound:(float)radius;

/**
 *  设置边框
 *
 *  @param color  边框颜色
 *  @param radius 边框半径
 *  @param width  边框宽度
 */
- (void)showBorderWithColor:(UIColor *)color radius:(CGFloat)radius width:(CGFloat)width;

/**
 *  设置阴影
 *
 *  @param color  阴影颜色
 *  @param offset 阴影偏移
 */
- (void)showShadowWithColor:(UIColor *)color offset:(CGSize)offset;

@end

@interface UIImage (Utils)

@property (nonatomic,readonly) NSData *data;

/**
 *  保持比例缩放到不超过最大尺寸，如果图片大小本来就小于最大尺寸则不缩放
 *
 *  @param image 要缩放的image
 *  @param size  指定最大不超过的尺寸
 *
 *  @return return 缩放后的图片
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledWithMaxSize:(CGSize)size;

/**
 *  不保持比例缩放到指定大小
 *
 *  @param image 要缩放的image
 *  @param size  指定尺寸
 *
 *  @return return 缩放后的图片
 */
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

/**
 *  根据颜色生成指定大小的image
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  生成可拉伸的图片
 *
 *  @param name 图片路径
 */
+ (UIImage *)resizedImageWithName:(NSString *)name;

@end

@interface UISearchBar (Utils)

@property (nonatomic,readonly) UIButton *cancelButton;

/**
 *  改变搜索框的取消按钮标题
 *
 *  @param title 取消按钮标题
 */
-(void)setCancelButtonTitle:(NSString *)title;

@end

@interface UIColor (Utils)

/**
 *  用16进制rgb字符串实例化对象
 *
 *  @param hexStr rgb字符串 不区分大小写 格式：ef2dec或者#3FEB4A 这两种都行
 */
+ (instancetype)colorWithRGBString:(NSString *)hexStr;

+ (UIColor *)colorWithRGBString:(NSString *)hexStr alpha:(CGFloat)alpha;

+ (instancetype)colorWithImage:(UIImage *)image fillSize:(CGSize)size;

@end

@interface UIViewController (Utils)

/**
 *  显示一个android风格的toast
 *
 *  @param message 显示的内容
 */
- (void)showToast:(NSString*)message;

/**
 *  显示一个简单的活动指示器
 */
- (void)beginLoadingAnimation:(NSString*)message;

/**
 *  隐藏活动指示器
 */
- (void)stopLoadingAnimation;

@end

@interface UIAlertView (Utils)

/**
 *  代替delegate
 */
@property (nonatomic) void(^clickedButton)(NSInteger,UIAlertView*);

/**
 *  然而这个block并不会被自动释放，所以你需要这个方法
 */
- (void)releaseBlock;

@end

@interface TextField:UITextField

@property (nonatomic,assign) IBInspectable NSUInteger maxLength;

@end

//@interface UITextView(Utils)
//
//+ (void)setupHook;
//
//@end

