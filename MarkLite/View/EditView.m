//
//  EditView.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2016年 zhubch. All rights reserved.
//

#import "EditView.h"
#import "Configure.h"
#import "MarkdownSyntaxGenerator.h"

@interface EditView ()

@property(nonatomic, strong) MarkdownSyntaxGenerator *markdownSyntaxGenerator;
@property(atomic,assign) BOOL hasNewTask;
@end

@implementation EditView
{
    UILabel *placeholderLable;
    NSOperationQueue *updateQueue;
    NSOperation *uiOperation;
}

- (id)initWithCoder:(NSCoder *) coder {
    NSLog(@"editview");

    self = [super initWithCoder:coder];

    if (self == nil) {
        return nil;
    }

    placeholderLable = [[UILabel alloc]initWithFrame:CGRectMake(5, 8, 100, 20)];
    placeholderLable.font = [UIFont systemFontOfSize:14];
    placeholderLable.text = ZHLS(@"StartEdit");
    placeholderLable.textColor = [UIColor lightGrayColor];
    [self addSubview:placeholderLable];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(updateSyntax) name:UITextViewTextDidChangeNotification object:nil];
    updateQueue = [[NSOperationQueue alloc]init];
    updateQueue.maxConcurrentOperationCount = 1;
    NSLog(@"editview");

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (MarkdownSyntaxGenerator *)markdownSyntaxGenerator {
    if (_markdownSyntaxGenerator == nil) {
        _markdownSyntaxGenerator = [[MarkdownSyntaxGenerator alloc] init];
    }
    return _markdownSyntaxGenerator;
}

- (void)updateSyntax {
    placeholderLable.hidden = self.text.length != 0;

    if (self.markedTextRange) { //中文选字的时候别刷新
        return;
    }
    [self highLightText];
//
//    NSOperation *op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(highLightText) object:nil];
//    [updateQueue cancelAllOperations];
//    [updateQueue addOperation:op];
}

- (void)highLightText
{
    NSArray *models = [self.markdownSyntaxGenerator syntaxModelsForText:self.text];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    UIFont *font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:[Configure sharedConfigure].fontSize];

    [attributedString addAttributes:@{
                                      NSFontAttributeName : font ? font : [UIFont systemFontOfSize:[Configure sharedConfigure].fontSize],
                                      NSForegroundColorAttributeName : [UIColor colorWithRGBString:@"0f2f2f"]
                                      } range:NSMakeRange(0, attributedString.length)];

    for (MarkdownSyntaxModel *model in models) {
        [attributedString addAttributes:AttributesFromMarkdownSyntaxType(model.type) range:model.range];
    }

    [self updateAttributedText:attributedString];
//    [uiOperation cancel];
//    uiOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(updateAttributedText:) object:attributedString];
//    [[NSOperationQueue mainQueue] addOperation:uiOperation];
}

- (void)updateAttributedText:(NSAttributedString *) attributedString {

    self.scrollEnabled = NO;
    NSRange selectedRange = self.selectedRange;
    self.attributedText = attributedString;
    self.selectedRange = selectedRange;
    self.scrollEnabled = YES;
}

@end
