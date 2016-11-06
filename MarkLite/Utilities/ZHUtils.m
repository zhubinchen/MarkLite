//
//  ZHUtils.m
//  ZHUtils
//
//  Created by zhubch on 15/7/28.
//  Copyright (c) 2016年 Robusoft. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "ZHUtils.h"

@implementation NSObject (ZHUtils)

@end

@implementation NSArray (ZHUtils)

- (NSString *)toString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data.toString;
}

@end

@implementation NSDictionary(ZHUtils)

- (NSString *)toString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return data.toString;
}

@end

@implementation NSData (ZHUtils)

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

@implementation NSString (ZHUtils)

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

@implementation NSDate (ZHUtils)

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

@implementation UIView (ZHUtils)

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

@implementation UIImage (ZHUtils)

- (UIImage *)fixOrientation{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (NSData *)data
{
    NSData *data = UIImagePNGRepresentation(self);
    if (data) {
        return data;
    }
    return UIImageJPEGRepresentation(self, 1);
}

- (UIImage *)scaleWithMaxSize:(CGSize)size
{
    CGSize imgSize = self.size;
    if (imgSize.width > size.width) {
        imgSize = CGSizeMake(size.width, size.width / imgSize.width * imgSize.height);
    }
    if (imgSize.height > size.height) {
        imgSize = CGSizeMake(size.height / imgSize.height * imgSize.width, size.height);
    }
    return [self scaleToSize:imgSize];
}

- (UIImage *)scaleToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
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

@implementation UISearchBar (ZHUtils)

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
//            [button setTintColor:kTintColor];
//            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateHighlighted];
            break;
        }
    }
}

@end

@implementation UIColor (ZHUtils)

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


@implementation UIAlertView (ZHUtils)

- (void)setClickedButton:(void (^)(NSInteger buttonIndex))clickedButton
{
    
    [self willChangeValueForKey:@"clickedButton"];
    objc_setAssociatedObject(self, "clickedButton",
                             clickedButton,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"clickedButton"];
    self.delegate = self;
}

- (void (^)(NSInteger ))clickedButton
{
    return objc_getAssociatedObject(self, "clickedButton");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.clickedButton) {
        self.clickedButton(buttonIndex);
    }
}

@end


@implementation UIActionSheet(ZHUtils)

- (void)setClickedButton:(void (^)(NSInteger buttonIndex))clickedButton
{
    
    [self willChangeValueForKey:@"clickedButton"];
    objc_setAssociatedObject(self, "clickedButton",
                             clickedButton,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:@"clickedButton"];
    self.delegate = self;
}

- (void (^)(NSInteger))clickedButton
{
    return objc_getAssociatedObject(self, "clickedButton");
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.clickedButton) {
        self.clickedButton(buttonIndex);
    }
}


@end

@implementation UITextField(ZHUtils)

- (void)setMaxLength:(NSUInteger)maxLength
{
    
    [self willChangeValueForKey:@"maxLength"];
    objc_setAssociatedObject(self, "maxLength",
                             [NSNumber numberWithInteger:maxLength],
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"maxLength"];
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (NSUInteger)maxLength
{
    return [objc_getAssociatedObject(self, "maxLength") integerValue];
}

- (void)textFieldDidChange:(UITextField*)textField
{
    if (self.maxLength == 0) {
        return;
    }
    if (textField.text.length > self.maxLength) {
        textField.text = [textField.text substringToIndex:self.maxLength];
    }
}

@end

