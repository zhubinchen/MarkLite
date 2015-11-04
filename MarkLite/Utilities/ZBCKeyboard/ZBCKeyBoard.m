//
//  ZBCKeyBoard.m
//  test
//
//  Created by Zhubch on 15-2-10.◉◉◉◉◉-
//  Copyright (c) 2015年 Zhubch. All rights reserved.
//

#import "ZBCKeyBoard.h"
#import "ZBCKeyButton.h"
#import "ZBCSwipeButton.h"
#import "ZBCTrackButton.h"

#define kCharacterButtonTag 1
#define kDeleteButtonTag 2
#define kReturnButtonTag 3
#define kShiftButtonTag 4
#define kSpaceButtonTag 5
#define kTabButtonTag 6
#define kHideButtonTag 7

#define kGrayColor     [UIColor colorWithWhite:0.85 alpha:1]
#define kTitleColor     [UIColor colorWithWhite:0.35 alpha:1]
#define kBlueColor     [UIColor colorWithRed:38/255.0 green:130/255.0 blue:213/255.0 alpha:1]

@interface ZBCKeyBoard () <ZBCKeyButtonDelegate,ZBCSwipeButtonDelegate,ZBCTrackButton>

@end

@implementation ZBCKeyBoard
{
    NSMutableArray *buttonArray;
    CGRect beginRect;
    UIImageView *bgView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        NSString *keys = @"QWERTYUIOPASDFGHJKLZXCVBNM";
        buttonArray = [NSMutableArray array];
        
        bgView = [[UIImageView alloc]init];
        [self addSubview:bgView];
        for (int i = 0; i < 26; i++) {
            ZBCKeyButton *btn = [[ZBCKeyButton alloc]init];
            btn.key = [keys substringWithRange:NSMakeRange(i, 1)];
            btn.upcase = NO;
            btn.color = [UIColor colorWithWhite:0.98 alpha:1];
            btn.pressedColor = kGrayColor;
            btn.textColor = kTitleColor;
            btn.tintTextcolor = kBlueColor;
            btn.delegate = self;
            btn.tag = kCharacterButtonTag;
            
            [buttonArray addObject:btn];
            
            [self addSubview:btn];
        }
        
        ZBCKeyButton *delBtn = [[ZBCKeyButton alloc]init];//26
        delBtn.imageName = @"left";
        delBtn.pressedImageName = @"left_press";
        delBtn.delegate = self;
        delBtn.color = kGrayColor;
        delBtn.pressedColor = [UIColor whiteColor];
        delBtn.tag = kDeleteButtonTag;
        [buttonArray addObject:delBtn];
        [self addSubview:delBtn];
        
        ZBCKeyButton *retBtn = [[ZBCKeyButton alloc]init];//27
        retBtn.key = @"Return";
        retBtn.upcase = NO;
        retBtn.color = kGrayColor;
        retBtn.pressedColor = [UIColor whiteColor];
        retBtn.textColor = [UIColor whiteColor];
        retBtn.tintTextcolor = kBlueColor;
        retBtn.delegate = self;
        retBtn.tag = kReturnButtonTag;
        [buttonArray addObject:retBtn];
        [self addSubview:retBtn];
        
        ZBCKeyButton *shiftBtn = [[ZBCKeyButton alloc]init];//28
        shiftBtn.imageName = @"up";
        shiftBtn.pressedImageName = @"up_press";
        shiftBtn.delegate = self;
        shiftBtn.color = kGrayColor;
        shiftBtn.pressedColor = [UIColor whiteColor];
        shiftBtn.tag = kShiftButtonTag;
        [buttonArray addObject:shiftBtn];
        [self addSubview:shiftBtn];
        
        ZBCKeyButton *spaceBtn = [[ZBCKeyButton alloc]init];//29
        spaceBtn.delegate = self;
        spaceBtn.color = [UIColor whiteColor];
        spaceBtn.pressedColor = kGrayColor;
        spaceBtn.tag = kSpaceButtonTag;
        [buttonArray addObject:spaceBtn];
        [self addSubview:spaceBtn];
        
        ZBCKeyButton *tabBtn = [[ZBCKeyButton alloc]init];//30
        tabBtn.delegate = self;
        tabBtn.key = @"tab";
        tabBtn.upcase = NO;
        tabBtn.color = kGrayColor;
        tabBtn.pressedColor = [UIColor whiteColor];
        tabBtn.textColor = [UIColor whiteColor];
        tabBtn.tintTextcolor = kBlueColor;
        tabBtn.tag = kTabButtonTag;
        [buttonArray addObject:tabBtn];
        [self addSubview:tabBtn];
        
        ZBCKeyButton *hideBtn = [[ZBCKeyButton alloc]init];//28
        hideBtn.imageName = @"down";
        hideBtn.pressedImageName = @"down_press";
        hideBtn.delegate = self;
        hideBtn.color = kGrayColor;
        hideBtn.pressedColor = [UIColor whiteColor];
        hideBtn.tag = kHideButtonTag;
        [buttonArray addObject:hideBtn];
        [self addSubview:hideBtn];
        
        keys = @"()<>\"[]{}'\\/$´`~^-|€£+=%*!?#@&_:;,.1203467589";
        for (int i = 0; i < 9; i++) {
            ZBCSwipeButton *btn = [[ZBCSwipeButton alloc]initWithFrame:CGRectZero];
            btn.keys = [keys substringWithRange:NSMakeRange(i*5, 5)];
            btn.color = [UIColor colorWithWhite:0.98 alpha:1];
            btn.pressedColor = kGrayColor;
            btn.textColor = kTitleColor;
            btn.pressedTextColor = kBlueColor;
            btn.tintTextcolor = [UIColor redColor];
            btn.delegate = self;
            [self addSubview:btn];
            [buttonArray addObject:btn];
        }
        
        ZBCTrackButton *trackBtn = [[ZBCTrackButton alloc]init];
        trackBtn.color = kBlueColor;
        trackBtn.pressedColor = [UIColor redColor];
        trackBtn.delegate = self;
        [self addSubview:trackBtn];
        [buttonArray addObject:trackBtn];
        
        self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.95 alpha:0.9];
        
        [self configureFrame];
        self.style = ZBCKeyBoardStyleDefault;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureFrame) name:UIDeviceOrientationDidChangeNotification object:nil];

    }
    
    return self;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    bgView.image = backgroundImage;
}

- (void)setStyle:(ZBCKeyBoardStyle)style
{
    _style = style;
    switch (style) {
        case ZBCKeyBoardStyleFlat:
            [buttonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *btn = obj;
                btn.alpha = 1;
                if (![obj isKindOfClass:[ZBCTrackButton class]]) {
                    btn.layer.cornerRadius = 0;
                    btn.layer.masksToBounds = YES;
                }
            }];
            bgView.hidden = YES;
            break;
        case ZBCKeyBoardStyleColorfull:
            [buttonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *btn = obj;
                btn.alpha = 0.4;
                
                if (![obj isKindOfClass:[ZBCTrackButton class]]) {
                    btn.layer.cornerRadius = 5;
                    btn.layer.masksToBounds = NO;
                }
            }];
            bgView.hidden = NO;
            break;
        case ZBCKeyBoardStyleSimulate:
            [buttonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *btn = obj;
                btn.alpha = 1;
                btn.layer.shadowColor = [UIColor grayColor].CGColor;
                btn.layer.shadowOffset = CGSizeMake(0.2, 0.2);
                btn.layer.shadowOpacity = 1;

                if (![obj isKindOfClass:[ZBCTrackButton class]]) {
                    btn.layer.cornerRadius = 5;
                    btn.layer.masksToBounds = NO;
                }
            }];
            bgView.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)pressedButton:(ZBCKeyButton *)button
{
    switch (button.tag) {
        case kCharacterButtonTag:
            [_editView insertText:[button titleForState:UIControlStateNormal]];
            break;
        case kDeleteButtonTag:
            [_editView deleteBackward];
            break;
        case kReturnButtonTag:
            [_editView insertText:@"\n"];
            break;
        case kTabButtonTag:
            [_editView insertText:@"\t"];
            break;
        case kSpaceButtonTag:
            [_editView insertText:@" "];
            break;
        case kHideButtonTag:
            [(UIResponder*)_editView resignFirstResponder];
            break;
        case kShiftButtonTag:
            [buttonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ZBCKeyButton *btn = obj;
                btn.upcase = !btn.upcase;
                if (idx == 25) {
                    *stop = YES;
                }
            }];
            break;

        default:
            break;
    }
}

- (void)choosedKey:(NSString *)key
{
    [_editView insertText:key];
}

- (void)trackedWithX:(CGFloat)x AndY:(CGFloat)y
{
    if (![_editView isKindOfClass:[UITextView class]]) {
        return;
    }
    UITextView *textView = (UITextView*)_editView;
    CGRect loc = beginRect;
    
    loc.origin.y -= textView.contentOffset.y;
    
    loc.origin.x -= x;
    loc.origin.y -= y;
    
    UITextPosition *p = [textView closestPositionToPoint:loc.origin];
    
    UITextRange *r = [textView textRangeFromPosition:p toPosition:p];
    
    textView.selectedTextRange = r;
}

- (void)trackStarted
{
    if ([_editView isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView*)_editView;
        beginRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    }
}

- (void)configureFrame
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat w = width/11;
    
    self.frame = CGRectMake(0, 0, width, 4*w);
    bgView.frame = self.bounds;
    
    [buttonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *v = obj;
        CGRect frame;
        if (idx < 10) {
            frame = CGRectMake(idx*w+0.05*w, 0+0.05*w, 0.9*w, 0.9*w);
        } else if (idx < 19) {
            frame = CGRectMake((idx-10)*w+w*0.5+w*0.05, w+0.05*w, 0.9*w, 0.9*w);
        } else if (idx < 26){
            frame = CGRectMake((idx-18)*w+w*0.05, w*2+w*0.05, 0.9*w, 0.9*w);
        } else if (idx == 26){
            frame = CGRectMake(10*w+w*0.05, 0+w*0.05, 0.9*w, 0.9*w);
        } else if (idx == 27) {
            frame = CGRectMake(9*w+w*0.5+w*0.05, w+w*0.05, 1.5*w-w*0.1, 0.9*w);
        } else if (idx == 28) {
            frame = CGRectMake(10*w+w*0.05, w*2+w*0.05, 0.9*w, 0.9*w);
        } else if (idx == 29) {
            frame = CGRectMake(w*4+w*0.05, w*3+w*0.05, 3*w - w*0.1, 0.9*w);
        } else if (idx == 30) {
            frame = CGRectMake(w*0.05, w*2+w*0.05, 0.9*w, 0.9*w);
        } else if (idx == 31) {
            frame = CGRectMake(10*w+w*0.05, w*3+w*0.05, 0.9*w, 0.9*w);
        } else if (idx < 36){
            frame = CGRectMake((idx-32)*w+w*0.05, w*3+w*0.05, 0.9*w, 0.9*w);
        } else if (idx < 39){
            frame = CGRectMake((idx-29)*w+w*0.05, w*3+w*0.05, 0.9*w, 0.9*w);
        } else if (idx < 41){
            frame = CGRectMake((idx-31)*w+w*0.05, w*2+w*0.05, 0.9*w, 0.9*w);
        } else {
            frame = CGRectMake(5.0*w+w*0.3, w*1.5+w*0.3, 0.4*w, 0.4*w);
            v.layer.masksToBounds = YES;
            v.layer.cornerRadius = 0.2*w;
        }
        v.frame = frame;
    }];
}



//- (UITextField *)findFistResponder:(UIView *)view {
//    for (UIView *child in view.subviews) {
//        if ([child respondsToSelector:@selector(isFirstResponder)]
//            &&
//            [child isFirstResponder]) {
//            return (UITextField *)child;
//        }
//        
//        UITextField *field = [self findFistResponder:child];
//        if (field) {
//            return field;
//        }
//    }
//    
//    return nil;
//}

@end
