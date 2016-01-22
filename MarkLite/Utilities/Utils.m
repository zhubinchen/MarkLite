//
//  Utils.m
//  GolfPKiOS
//
//  Created by zhubch on 15/7/28.
//  Copyright (c) 2015年 Robusoft. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

@implementation NSObject (Utils)

@end

@implementation NSData (Utils)

- (NSDictionary *)toDictionay
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
    return dic;
}

- (NSString*)toString
{
    NSString *s = [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];
    return s;
}

@end

@implementation NSString (Utils)

+ (instancetype)uniqueString
{
    NSDate *date = [NSDate date];
    return date.absluteTime.md5Hash;
}

- (BOOL)isValidPassword
{
    if (self.length == 0) {
        return NO;
    }
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"^([a-z]+(?=[0-9])|[0-9]+(?=[a-z]))[a-z0-9]+$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange matchedRange = [exp rangeOfFirstMatchInString:self options:NSMatchingAnchored range:NSMakeRange(0, self.length)];
    return matchedRange.length == self.length;
}

- (NSAttributedString *)stringWithMiddleLine
{
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    return [[NSMutableAttributedString alloc]initWithString:self attributes:attribtDic];
}

- (NSString *)urlEncodeString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                            NULL,
                                            kCFStringEncodingUTF8));
    return encodedString;
}

- (BOOL)isValidPhone
{
    if (self.length == 0) {
        return NO;
    }
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange matchedRange = [exp rangeOfFirstMatchInString:self options:NSMatchingAnchored range:NSMakeRange(0, self.length)];
    return matchedRange.length == self.length;
}

- (NSString *)md5Hash
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

+ (NSString *)stringWithCurrentTime
{
    NSDateFormatter *daterformatter=[[NSDateFormatter alloc]init];
    
    [daterformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    daterformatter.locale=[NSLocale currentLocale];
    
    NSMutableString *string=[[NSMutableString alloc]initWithString:[daterformatter stringFromDate:[NSDate date ]]];
    return string;
}

+ (NSString *)documentPath
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:self
     attributes:attributes];
    CGSize size = [attributedText boundingRectWithSize:maxSize
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil].size;
    return size;
}

@end

@implementation NSDate (Utils)

- (NSString *)date
{
    return [self.formatDate substringWithRange:NSMakeRange(0, 10)];
}

- (NSString *)time
{
    return [self.formatDate substringWithRange:NSMakeRange(11, 8)];
}

+ (instancetype)dateWithString:(NSString *)str
{
    NSString *format = @"yyyy-MM-dd HH:mm:ss";
    
    NSDateFormatter *daterformatter=[[NSDateFormatter alloc]init];
    
    [daterformatter setDateFormat:[format substringToIndex:str.length]];
    
    daterformatter.locale=[NSLocale currentLocale];
    
    return [daterformatter dateFromString:str];
}

- (NSString *)absluteTime
{
    return [NSString stringWithFormat:@"%f",self.timeIntervalSince1970];
}

- (NSString *)formatDate
{
    NSDateFormatter *daterformatter=[[NSDateFormatter alloc]init];
    
    [daterformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    daterformatter.locale=[NSLocale currentLocale];
    
    NSMutableString *string=[[NSMutableString alloc]initWithString:[daterformatter stringFromDate:self]];
    return string;
}

+ (NSString *)formatWithAbsluteTime:(NSString *)absTime
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:absTime.doubleValue];
    return date.formatDate;
}

@end

@implementation UIView (Utils)

@dynamic borderColor;
@dynamic borderRadius;
@dynamic borderWidth;

- (UIImage *)snap
{
    return [self snapInRect:self.bounds];
}

- (UIImage *)snapInRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL)
    {
        return nil;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    
    //[self layoutIfNeeded];
    
    if( [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    }
    else
    {
        [self.layer renderInContext:context];
    }
    
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    //    image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    
    return image;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.masksToBounds = YES;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderRadius:(CGFloat)borderRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = borderRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = borderWidth;
}

- (void)showBorderWithColor:(UIColor *)color radius:(CGFloat)radius width:(CGFloat)width
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = width;
    self.layer.borderColor = color.CGColor;
}

- (void)makeRound:(float)radius
{
    [self showBorderWithColor:[UIColor clearColor] radius:radius width:1.0];
}

- (void)showShadowWithColor:(UIColor *)color offset:(CGSize)offset
{
    self.layer.shadowOffset = offset;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowColor = color.CGColor;
    self.clipsToBounds = NO;
}

@end

@implementation UIImage (Utils)

- (NSData *)data
{
    NSData *data = UIImagePNGRepresentation(self);
    if (data) {
        return data;
    }
    return UIImageJPEGRepresentation(self, 1);
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledWithMaxSize:(CGSize)size
{
    CGSize imgSize = image.size;
    if (imgSize.width > size.width) {
        imgSize = CGSizeMake(size.width, size.width / imgSize.width * imgSize.height);
    }
    if (imgSize.height > size.height) {
        imgSize = CGSizeMake(size.height / imgSize.height * imgSize.width, size.height);
    }
    return [self imageWithImage:image scaledToSize:imgSize];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size

{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context,
                                   
                                   color.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+ (UIImage *)resizedImageWithName:(NSString *)name
{
    UIImage *image = [self imageNamed:name];
    // 指定为拉伸模式，伸缩后重新赋值
    image = [image stretchableImageWithLeftCapWidth:image.size.width *0.5 topCapHeight:image.size.height *0.75];
    return image;
}

@end

@implementation UISearchBar (Utils)

@dynamic cancelButton;

- (UIButton *)cancelButton
{
    UIView *view=self.subviews[0];
    
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button=(UIButton *)subView;
            return button;
        }
    }
    return nil;
}

-(void)setCancelButtonTitle:(NSString *)title
{
    UIView *view=self.subviews[0];
    
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button=(UIButton *)subView;
            [button setTintColor:[UIColor blackColor]];
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateHighlighted];
            break;
        }
    }
}

@end

@implementation UIColor (Utils)

+ (UIColor *)colorWithRGBString:(NSString *)hexStr alpha:(CGFloat)alpha
{
    NSString *cString = [[hexStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return nil;
    
    NSRange range;
    range.length = 2;
    
    range.location = 0;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

+ (UIColor *)colorWithRGBString:(NSString *)hexStr
{
    return [self colorWithRGBString:hexStr alpha:1.0];
}

+ (UIColor *)colorWithImage:(UIImage *)image fillSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [UIColor colorWithPatternImage:newImage];
}

@end

static void (^block)(NSInteger,UIAlertView*) = nil;

@implementation UIAlertView (Utils)

@dynamic clickedButton;

- (void)setClickedButton:(void (^)(NSInteger buttonIndex,UIAlertView* alertView))clickedButton
{
    block = clickedButton;
    self.delegate = self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (block) {
        block(buttonIndex,alertView);
    }
}

- (void)releaseBlock
{
//    Block_release(block);
    block = nil;
}

@end

@implementation TextField

- (void)setMaxLength:(NSUInteger )maxLength
{
    _maxLength = maxLength;
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField*)textField
{
    if (_maxLength == 0) {
        return;
    }
    if (textField.text.length > _maxLength) {
        textField.text = [textField.text substringToIndex:_maxLength];
    }
}

@end

//@implementation UITextView (Utils)
//
//+ (void)setupHook
//{
//    static BOOL install = NO;
//    if (!install) {
//        install = YES;
//        Class klass = [UITextView class];
//        Method orgMethod = class_getInstanceMethod(klass, @selector(replaceRange:withText:));
//        Method myMethod = class_getInstanceMethod(klass, @selector(myReplaceRange:withText:));
//        method_exchangeImplementations(orgMethod, myMethod);
//        orgMethod = class_getInstanceMethod(klass, @selector(setMarkedText:selectedRange:));
//        myMethod = class_getInstanceMethod(klass, @selector(mySetMarkedText:selectedRange:));
//        method_exchangeImplementations(orgMethod, myMethod);
//        orgMethod = class_getInstanceMethod(klass, @selector(insertText:));
//        myMethod = class_getInstanceMethod(klass, @selector(myInsertText:));
//        method_exchangeImplementations(orgMethod, myMethod);
//        orgMethod = class_getInstanceMethod(klass, @selector(deleteBackward));
//        myMethod = class_getInstanceMethod(klass, @selector(myDeleteBackward));
//        method_exchangeImplementations(orgMethod, myMethod);
//    }
//}
//
//- (void)myReplaceRange:(UITextRange *)range withText:(NSString *)text
//{
//    [self.undoManager beginUndoGrouping];
//    [self myReplaceRange:range withText:text];
//    [self.undoManager endUndoGrouping];
//}
//
//- (void)mySetMarkedText:(NSString *)text selectedRange:(NSRange)range
//{
//    if (0 < text.length) {
//        [self.undoManager beginUndoGrouping];
//        [self mySetMarkedText:text selectedRange:range];
//        [self.undoManager endUndoGrouping];
//    }
//}
//
//-(void)myInsertText:(NSString *)text
//{
//    [self.undoManager beginUndoGrouping];
//    [self myInsertText:text];
//    [self.undoManager endUndoGrouping];
//}
//
//-(void)myDeleteBackward
//{
//    [self.undoManager beginUndoGrouping];
//    [self myDeleteBackward];
//    [self.undoManager endUndoGrouping];
//}
//
//@end

