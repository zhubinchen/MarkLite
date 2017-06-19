//
//  ZHUtils.h
//  ZHUtils
//
//  Created by Bingcheng on 15/7/28.
//  Copyright (c) 2016年 Robusoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define kWindowHeight ([UIApplication sharedApplication].keyWindow.bounds.size.height)

#define kWindowWidth ([UIApplication sharedApplication].keyWindow.bounds.size.width)

#define kDeviceSimulator [[UIDevice currentDevice].model hasSuffix:@"Simulator"]

#define kDevicePhone ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)

#define kDevicePad   ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)

#define kSystemVersion   [[UIDevice currentDevice].systemVersion floatValue]

#define kAppVersionNo [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"]

#define ZHLS(key) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]


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
 *  边框颜色，支持可视化修改
 */
@property (nonatomic,strong) IBInspectable UIColor *shadowColor;
/**
 *  边框宽度，支持可视化修改
 */
@property (nonatomic,assign) IBInspectable CGFloat shadowWidth;
/**
 *  边框半径。支持可视化修改
 */
@property (nonatomic,assign) IBInspectable CGFloat shadowRadius;

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

- (UIImage *)fixOrientation;
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

@property (nonatomic,strong) void(^clickedButton)(NSInteger);

@end

/**
 *  支持block回调的ActionSheet
 */
@interface UIActionSheet(ZHUtils) <UIActionSheetDelegate>

@property (nonatomic,strong) void(^clickedButton)(NSInteger);

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
    CGSize  size = [message sizeWithFont:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(kWindowWidth - 20, 40)];
    CGFloat w = size.width + 20;
    CGFloat h = size.height + 15;
    
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake((kWindowWidth - w) * 0.5,kWindowHeight - 80 - h, w, h)];
    [l showBorderWithColor:[UIColor colorWithRGBString:@"1A1D24"] radius:5 width:1.5];
    l.numberOfLines = 0;
    l.text = message;
    l.textColor = [UIColor colorWithRGBString:@"1A1D24"];
    l.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    l.font = [UIFont systemFontOfSize:14];
    l.textAlignment = NSTextAlignmentCenter;
    l.tag = 52684653;
    l.alpha = 0.5;
    
    [window addSubview:l];
    
    [UIView animateWithDuration:0.15 animations:^{
        l.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.75 animations:^{
                    l.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [l removeFromSuperview];
                }];
            });
        }
    }];
}

static inline void beginLoadingAnimationOnParent(UIView *parent){
    
    UIView *bg = [parent viewWithTag:52684654];
    if (bg) {
        [bg removeFromSuperview];
    }
    bg = [[UIView alloc]initWithFrame:parent.bounds];
    bg.backgroundColor = [UIColor clearColor];
    bg.tag = 52684654;
    [parent addSubview:bg];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.color = [UIColor colorWithRGBString:@"7649D6"];
    activity.center = bg.center;
    [activity startAnimating];
    [bg addSubview:activity];
}

static inline void beginLoadingAnimation(){
    UIWindow *window=[[[UIApplication sharedApplication] delegate] window];
    beginLoadingAnimationOnParent(window);
}

static inline void stopLoadingAnimationOnParent(UIView *parent){
    UIView *v = [parent viewWithTag:52684654];
    [v removeFromSuperview];
}

static inline void stopLoadingAnimation(){
    UIWindow *window=[[[UIApplication sharedApplication] delegate] window];
    stopLoadingAnimationOnParent(window);
}

static inline NSString* stringFromInt(int num){
    return [NSString stringWithFormat:@"%d",num];
}

static inline NSString* stringFromFloat(float num){
    return [NSString stringWithFormat:@"%.4f",num];
}

static inline NSString *documentPath(){
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

static inline UIFont *fontOfSize(CGFloat size){
    return [UIFont fontWithName:@"KaiTi_GB2312" size:size + 2];
}
