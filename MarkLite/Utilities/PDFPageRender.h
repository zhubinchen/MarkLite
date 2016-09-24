//
//  PDFPageRender.h
//  MarkLite
//
//  Created by zhubch on 9/24/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFPageRender : UIPrintPageRenderer

@property (nonatomic,assign) CGFloat paperWidth;
@property (nonatomic,assign) CGFloat paperHeight;

- (NSData*)renderPDFFromHtmlString:(NSString*)htmlString;

@end
