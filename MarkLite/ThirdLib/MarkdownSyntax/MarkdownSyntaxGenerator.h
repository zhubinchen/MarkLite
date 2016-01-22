//
// Created by azu on 2013/10/26.
//


#import <Foundation/Foundation.h>
#import "MarkdownSyntaxModel.h"


extern NSRegularExpression* NSRegularExpressionFromMarkdownSyntaxType(MarkdownSyntaxType v);
extern NSDictionary* AttributesFromMarkdownSyntaxType(MarkdownSyntaxType v);

@interface MarkdownSyntaxGenerator : NSObject
- (NSArray *)syntaxModelsForText:(NSString *) text;
@end