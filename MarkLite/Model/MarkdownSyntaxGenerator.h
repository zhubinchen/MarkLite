//
//  MarkdownSyntaxGenerator.h
//  MarkLite
//
//  Created by zhubch on 11/12/15.
//  Copyright © 2016 zhubch. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MarkdownSyntaxModel.h"


extern NSRegularExpression* NSRegularExpressionFromMarkdownSyntaxType(MarkdownSyntaxType v);
extern NSDictionary* AttributesFromMarkdownSyntaxType(MarkdownSyntaxType v);

@interface MarkdownSyntaxGenerator : NSObject
- (NSArray *)syntaxModelsForText:(NSString *) text;
@end
