//
//  PDFPageRender.m
//  MarkLite
//
//  Created by zhubch on 9/24/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "PDFPageRender.h"

@implementation PDFPageRender

- (instancetype)init
{
    if (self = [super init]) {
        self.headerHeight = 40.0;
        self.footerHeight = 40.0;
        self.paperWidth = 595.2;
        self.paperHeight = 841.8;
    }
    return self;
}

- (CGRect)paperRect
{
    return CGRectMake(0, 0, _paperWidth, _paperHeight);
}

- (CGRect)printableRect
{
    return CGRectMake(20, 20, _paperWidth - 20 , _paperHeight - self.headerHeight - self.footerHeight);
}

- (NSData *)renderPDFFromHtmlString:(NSString *)htmlString
{
    UIMarkupTextPrintFormatter *formatter = [[UIMarkupTextPrintFormatter alloc]initWithMarkupText:htmlString];
    [self addPrintFormatter:formatter startingAtPageAtIndex:0];
    
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    for (NSInteger i=0; i < self.numberOfPages; i++)
    {
        UIGraphicsBeginPDFPage();
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        [self drawPageAtIndex:i inRect:bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}

- (void)drawHeaderForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)headerRect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);  //线宽
    CGContextSetStrokeColor(context, CGColorGetComponents([UIColor colorWithRGBString:@"3f3f3f"].CGColor));
    CGContextSetAllowsAntialiasing(context, true);
    
    CGContextMoveToPoint(context, 20, 40);  //起点坐标
    CGContextAddLineToPoint(context, _paperWidth, 40);   //终点坐标
    CGFloat arr[] = {3,1};
    //下面最后一个参数“2”代表排列的个数。
    CGContextSetLineDash(context, 0, arr, 2);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    NSString *headerText = @"Generate By MarkLite";
    
    UIFont *font = [UIFont fontWithName:@"Didot-Italic" size:18];
    NSDictionary *attribute = @{
                                NSFontAttributeName : font ? font : [UIFont systemFontOfSize:18],
                                NSForegroundColorAttributeName : [UIColor colorWithRGBString:@"0f2f2f"]
                                };
    CGSize size = [headerText sizeWithAttributes:attribute];
    [headerText drawInRect:CGRectMake(self.paperRect.size.width - size.width , 20 - size.height / 2, size.width, size.height) withAttributes:attribute];
}

- (void)drawFooterForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)footerRect
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    NSDictionary *attribute = @{
                                NSFontAttributeName : font ? font : [UIFont systemFontOfSize:18],
                                NSForegroundColorAttributeName : [UIColor colorWithRGBString:@"0f2f2f"]
                                };
    NSString *headerText = [NSString stringWithFormat:@"%li",(long)pageIndex + 1];

    CGSize size = [headerText sizeWithAttributes:attribute];
    [headerText drawInRect:CGRectMake(_paperWidth/2 - size.width / 2, footerRect.origin.y + 15 - size.height / 2, size.width, size.height) withAttributes:attribute];
}

@end
