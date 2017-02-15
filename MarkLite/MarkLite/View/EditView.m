//
//  EditView.m
//  MarkLite
//
//  Created by Bingcheng on 15-3-27.
//  Copyright (c) 2016年 Bingcheng. All rights reserved.
//

#import "EditView.h"
#import "Configure.h"
#import "MarkdownSyntaxGenerator.h"

@interface EditView ()<UITextViewDelegate>

@end

@implementation EditView
{
    UILabel *placeholderLable;
}

- (id)initWithCoder:(NSCoder *) coder {

    self = [super initWithCoder:coder];
    if (self == nil) {
        return nil;
    }

    placeholderLable = [[UILabel alloc]initWithFrame:CGRectMake(5, 8, 100, 20)];
    placeholderLable.font = [UIFont systemFontOfSize:14];
    placeholderLable.text = ZHLS(@"StartEdit");
    placeholderLable.textColor = [UIColor lightGrayColor];
    [self addSubview:placeholderLable];

    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    return self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateSyntax];
}

- (void)textChanged:(NSNotification *)notification
{
    [self updateSyntax];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updateSyntax];
}

- (void)insertText:(NSString *)text
{
    [super insertText:text];
    [self updateSyntax];
}

- (void)updateSyntax {
    placeholderLable.hidden = self.text.length != 0;

    if (self.markedTextRange) { //中文选字的时候别刷新
        return;
    }
    [self highLightText];
}

- (void)highLightText
{
    NSLog(@"highlight begin");
    self.textChanged(self.text);
    [self updateAttributedText:syntaxModelsForText(self.text)];
    NSLog(@"highlight end");
}

- (void)updateAttributedText:(NSAttributedString *) attributedString {

    self.scrollEnabled = NO;
    NSRange selectedRange = self.selectedRange;
    self.attributedText = attributedString;
    self.selectedRange = selectedRange;
    self.scrollEnabled = YES;
}

- (void)dealloc
{
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
}

@end
