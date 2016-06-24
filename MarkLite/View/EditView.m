//
//  EditView.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "EditView.h"
#import "MarkdownSyntaxGenerator.h"

@interface EditView ()

@property(nonatomic, strong) MarkdownSyntaxGenerator *markdownSyntaxGenerator;
@property(atomic,assign) BOOL updating;
@end

@implementation EditView
{
    dispatch_queue_t updateQueue;
    UILabel *placeholderLable;
}

- (id)initWithCoder:(NSCoder *) coder {
    self = [super initWithCoder:coder];
    if (self == nil) {
        return nil;
    }

    placeholderLable = [[UILabel alloc]initWithFrame:CGRectMake(5, 8, 100, 20)];
    placeholderLable.font = [UIFont systemFontOfSize:14];
    placeholderLable.text = @"现在开始编辑吧";
    placeholderLable.textColor = [UIColor lightGrayColor];
    [self addSubview:placeholderLable];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(didTextChangeText:) name:UITextViewTextDidChangeNotification object:nil];
    updateQueue = dispatch_queue_create("update", DISPATCH_QUEUE_CONCURRENT);
    [self updateSyntax];
    return self;
}

- (void)dealloc {
    updateQueue = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didTextChangeText:(id)sender{
    [self updateSyntax];
}

- (MarkdownSyntaxGenerator *)markdownSyntaxGenerator {
    if (_markdownSyntaxGenerator == nil) {
        _markdownSyntaxGenerator = [[MarkdownSyntaxGenerator alloc] init];
    }
    return _markdownSyntaxGenerator;
}

- (void)updateSyntax {
    placeholderLable.hidden = self.text.length != 0;
    
    if (self.markedTextRange) {
        return;
    }
    dispatch_async(updateQueue, ^{
        NSArray *models = [self.markdownSyntaxGenerator syntaxModelsForText:self.text];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        [attributedString addAttributes:@{
                                          NSFontAttributeName : [UIFont fontWithName:@"Hiragino Sans" size:15],
                                          NSForegroundColorAttributeName : [UIColor colorWithRGBString:@"1D1D44"]
                                          } range:NSMakeRange(0, attributedString.length)];
        for (MarkdownSyntaxModel *model in models) {
            [attributedString addAttributes:AttributesFromMarkdownSyntaxType(model.type) range:model.range];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateAttributedText:attributedString];
        });
    });
}

- (void)updateAttributedText:(NSAttributedString *) attributedString {
    self.scrollEnabled = NO;
    NSRange selectedRange = self.selectedRange;
    self.attributedText = attributedString;
    self.selectedRange = selectedRange;
    self.scrollEnabled = YES;
}

@end
