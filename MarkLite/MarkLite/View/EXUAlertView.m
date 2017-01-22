//
//  EXUAlertView.m
//  chacha
//
//  Created by Bingcheng on 2016/12/2.
//  Copyright © 2016年 EXUTECH. All rights reserved.
//

#import "EXUAlertView.h"
#import "ZHUtils.h"
#import "AppDelegate.h"

@interface EXUAlertView ()

@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *height;

@end

static EXUAlertView *currentAlertView = nil;

@implementation EXUAlertView
{
    NSMutableArray *buttonArray;
    CGFloat contentWidth;
    CGFloat beginY;
    BOOL singleRow;
    BOOL custom;
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"EXUAlertView" owner:nil options:nil] lastObject];
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancel:)];
    [self addGestureRecognizer:ges];
    self.frame = CGRectMake(0, 0, kWindowWidth, kWindowHeight);
    contentWidth = 280;
    NSMutableArray<NSString *> *buttonTitles = [NSMutableArray array];
    va_list args;
    va_start(args, otherButtonTitles);
    if (cancelButtonTitle.length) {
        [buttonTitles addObject:cancelButtonTitle];
    }
    if (otherButtonTitles)
    {
        [buttonTitles addObject:otherButtonTitles];
        while ((otherButtonTitles = va_arg(args, NSString *)))
        {
            [buttonTitles addObject:otherButtonTitles];
        }
    }
    va_end(args);
    self.titleLabel.text = title;
    

    if (buttonTitles.count == 2) {
        CGFloat w1 = [buttonTitles[0] sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(1000, 16)].width;
        CGFloat w2 = [buttonTitles[1] sizeWithFont:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(1000, 16)].width;
        if (w1*2.1 < contentWidth && w2*2.1 < contentWidth){
            singleRow = YES;
        }
    }

    [self setupButtonWithTitles:buttonTitles];
    self.buttonHeight = 53;

    return self;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    return [buttonArray[buttonIndex] currentTitle];
}

- (void)layoutSubviews
{
    if (singleRow) {
        UIButton *btn = buttonArray[0];
        btn.frame = CGRectMake(0, beginY, contentWidth * 0.5, _buttonHeight);
        btn = buttonArray[1];
        btn.frame = CGRectMake(contentWidth * 0.5, beginY, contentWidth * 0.5, _buttonHeight);
    }else{
        for (int i = 0; i < buttonArray.count; i++) {
            UIButton *btn = buttonArray[i];
            btn.frame = CGRectMake(0, beginY + i * _buttonHeight, contentWidth, _buttonHeight);
        }
    }
}

- (void)setButtonHeight:(CGFloat)buttonHeight
{
    _buttonHeight = buttonHeight;
    beginY = 100;
    
    if (singleRow) {
        self.height.constant = _buttonHeight + beginY;
    }else{
        self.height.constant = buttonArray.count * _buttonHeight + beginY;
    }
    [self layoutIfNeeded];
}

- (NSArray<UIButton *> *)buttons
{
    return buttonArray;
}

- (void)setupButtonWithTitles:(NSArray<NSString *>*)buttonTitles
{
    buttonArray = [NSMutableArray array];
    [buttonTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:obj forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        btn.tag = idx;
        btn.tintColor = kPrimaryColor;
        [self.contentView addSubview:btn];
        [buttonArray addObject:btn];
        if (idx == 0) {
            btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
        }else{
            btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        }
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(-1, 0, 0.5, 53)];
        line.backgroundColor = kPrimaryColor;
        [btn addSubview:line];
        line = [[UIView alloc]initWithFrame:CGRectMake(0, -1, contentWidth, 0.5)];
        line.backgroundColor = kPrimaryColor;
        [btn addSubview:line];
    }];
}


- (void)didClickButton:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:sender.tag];
    }
    if (self.clickedButton) {
        self.clickedButton(sender.tag);
    }
    [self dismiss];
}

- (void)show
{
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    [win addSubview:self];
    currentAlertView = self;
}

- (IBAction)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:0];
    }
    if (self.clickedButton) {
        self.clickedButton(0);
    }
    [self dismiss];
}

- (void)dismiss
{
    currentAlertView = nil;
    [self removeFromSuperview];
}

- (BOOL)visible
{
    return currentAlertView == self;
}

+ (instancetype)currentAlertView
{
    return currentAlertView;
}

@end
