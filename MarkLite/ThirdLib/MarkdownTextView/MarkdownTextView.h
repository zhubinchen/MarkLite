//
// Created by azu on 2013/10/26.
//


#import <Foundation/Foundation.h>

@class MarkdownSyntaxGenerator;


@interface MarkdownTextView : UITextView <UITextViewDelegate>

- (void)updateSyntax;

@end