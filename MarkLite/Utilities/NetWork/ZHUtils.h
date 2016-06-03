//
//  ZHUtils.h
//  ZHUtils
//
//  Created by zhubch on 15/7/28.
//  Copyright (c) 2015年 Robusoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

#define kDeviceSimulator [[UIDevice currentDevice].model hasSuffix:@"Simulator"]

#define kDevicePhone ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)

#define kDevicePad   ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)

#define kSystemVersion   [[UIDevice currentDevice].systemVersion floatValue]

@interface NSObject (ZHUtils)

@end

@interface NSArray (ZHUtils)

- (NSString*)toString;

@end

@interface NSDictionary (ZHUtils)

- (NSString*)toString;

@end

/**
 *  方便调试
 */
@interface NSData (ZHUtils)

- (NSDictionary*)toDictionay;

- (NSString*)toString;

@end

@interface NSString (ZHUtils)

/**
 *  判断手机号码格式合法
 */
@property (nonatomic,readonly) BOOL isValidPhone;

@property (nonatomic,readonly) BOOL isValidPassword;

@property (nonatomic,readonly) NSString *md5Hash;

@property (nonatomic,readonly) NSString *urlEncodeString;

/**
 *  生成不重复的字符串
 */
+ (instancetype)uniqueString;

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
 *  当前时间
 */
+ (NSString*)stringWithCurrentTime;

/**
 *  document目录
 */
+ (NSString*)documentPath;

@end

@interface NSDate (ZHUtils)

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

@interface UIView (ZHUtils)

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

/**
 *  矩形内的截图
 */
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

@interface UIImage (ZHUtils)

@property (nonatomic,readonly) NSData *data;

/**
 *  保持比例缩放到不超过最大尺寸，如果图片大小本来就小于最大尺寸则不缩放
 *
 *  @param size  指定最大不超过的尺寸
 *
 *  @return return 缩放后的图片
 */
- (UIImage *)scaleWithMaxSize:(CGSize)size;

/**
 *  不保持比例缩放到指定大小
 *
 *  @param size  指定尺寸
 *
 *  @return return 缩放后的图片
 */
- (UIImage *)scaleToSize:(CGSize)newSize;

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

@interface UISearchBar (ZHUtils)

@property (nonatomic,readonly) UIButton *cancelButton;

/**
 *  改变搜索框的取消按钮标题
 *
 *  @param title 取消按钮标题
 */
-(void)setCancelButtonTitle:(NSString *)title;

@end

@interface UIColor (ZHUtils)

/**
 *  用16进制rgb字符串实例化对象
 *
 *  @param hexStr rgb字符串 不区分大小写 格式：ef2dec或者#3FEB4A 这两种都行
 */
+ (instancetype)colorWithRGBString:(NSString *)hexStr;

+ (instancetype)colorWithRGBString:(NSString *)hexStr alpha:(CGFloat)alpha;

+ (instancetype)colorWithImage:(UIImage *)image fillSize:(CGSize)size;

@end

/**
 *  支持block回调的AlertView
 */
@interface UIAlertView(ZHUtils)

@property (nonatomic,strong) void(^clickedButton)(NSInteger,UIAlertView*);

@end

/**
 *  支持block回调的ActionSheet
 */
@interface UIActionSheet(ZHUtils) <UIActionSheetDelegate>

@property (nonatomic,strong) void(^clickedButton)(NSInteger,UIActionSheet*);

@end

@interface UITextField(ZHUtils)

@property (nonatomic,assign) IBInspectable NSUInteger maxLength;

@end

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

static inline void showToast(NSString *message){
    
    UIWindow *window=[[[UIApplication sharedApplication] delegate] window];
    
    UIView *oldView = [window viewWithTag:52684653];
    
    [oldView removeFromSuperview];
    
    if (message.length < 1) {
        return;
    }
    CGSize  size = [message sizeWithFont:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(kScreenWidth - 20, 40)];
    CGFloat w = size.width + 20;
    CGFloat h = size.height + 10;
    
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth - w) * 0.5,kScreenHeight - 60 - h, w, h)];
    l.numberOfLines = 0;
    l.text = message;
    l.textColor = [UIColor whiteColor];
    l.backgroundColor = [UIColor darkGrayColor];
    l.font = [UIFont systemFontOfSize:14];
    l.textAlignment = NSTextAlignmentCenter;
    l.tag = 52684653;
    [l makeRound:5];
    l.alpha = 0.5;
    
    [window addSubview:l];
    
    [UIView animateWithDuration:0.15 animations:^{
        l.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{
                    l.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [l removeFromSuperview];
                }];
            });
        }
    }];
}

static inline void beginLoadingAnimation(NSString *message){
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    UIView *oldView = [window viewWithTag:52684654];
    if (oldView) {
        [oldView removeFromSuperview];
    }
    
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    v.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [v makeRound:5];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.center = CGPointMake(40, 30);
    [activity startAnimating];
    [v addSubview:activity];
    
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, 86, 20)];
    l.textAlignment = NSTextAlignmentCenter;
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont systemFontOfSize:12];
    l.text = message;
    [v addSubview:l];
    
    UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    bg.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
    bg.tag = 52684654;
    v.center = bg.center;
    [bg addSubview:v];
    [window addSubview:bg];
}

static inline void stopLoadingAnimation(){
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    UIView *v = [window viewWithTag:52684654];
    [v removeFromSuperview];
}

static inline NSString* stringFromInt(int num){
    return [NSString stringWithFormat:@"%d",num];
}

static inline NSString* stringFromFloat(float num){
    return [NSString stringWithFormat:@"%.4f",num];
}
