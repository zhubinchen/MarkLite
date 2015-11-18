//
// Created by azu on 2013/10/26.
//


#import "MarkdownTextView.h"
#import "MarkdownSyntaxGenerator.h"

@interface MarkdownTextView ()

@property(nonatomic, strong) MarkdownSyntaxGenerator *markdownSyntaxGenerator;

@end

@implementation MarkdownTextView
{
    dispatch_queue_t updateQueue;
}

- (id)initWithCoder:(NSCoder *) coder {
    self = [super initWithCoder:coder];
    if (self == nil) {
        return nil;
    }
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
    dispatch_async(updateQueue, ^{
        NSArray *models = [self.markdownSyntaxGenerator syntaxModelsForText:self.text];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        [attributedString addAttributes:@{
                                         NSFontAttributeName : [UIFont systemFontOfSize:15],
                                         NSForegroundColorAttributeName : [UIColor darkGrayColor]
                                         } range:NSMakeRange(0, attributedString.length)];
        for (MarkdownSyntaxModel *model in models) {
            [attributedString addAttributes:AttributesFromMarkdownSyntaxType(
                                                                             model.type) range:model.range];
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