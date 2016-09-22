//
//  UIPrintPageRenderer+PDF.m
//  MarkLite
//
//  Created by zhubch on 9/22/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "UIPrintPageRenderer+PDF.h"

@implementation UIPrintPageRenderer (PDF)

- (NSData*)printToPDF
{    
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, CGRectZero, nil );
    
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

@end
