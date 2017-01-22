//
//  PDFPageRender.m
//  MarkLite
//
//  Created by Bingcheng on 9/24/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "PDFPageRender.h"

@implementation PDFPageRender

- (instancetype)init
{
    if (self = [super init]) {
        self.headerHeight = 0.0;
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
    return CGRectMake(20, 20, _paperWidth - 20 , _paperHeight - 20 - self.footerHeight);
}

- (NSData *)renderPDFFromHtmlString:(NSString *)htmlString
{
    UIMarkupTextPrintFormatter *formatter = [[UIMarkupTextPrintFormatter alloc]initWithMarkupText:htmlString];
    [self addPrintFormatter:formatter startingAtPageAtIndex:0];
    
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
    for (NSInteger i = 0; i < self.numberOfPages; i++)
    {
        UIGraphicsBeginPDFPage();
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        [self drawPageAtIndex:i inRect:bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
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
