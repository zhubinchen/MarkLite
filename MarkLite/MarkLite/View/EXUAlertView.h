//
//  EXUAlertView.h
//  chacha
//
//  Created by Bingcheng on 2016/12/2.
//  Copyright © 2016年 EXUTECH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EXUAlertView;

@protocol EXUAlertViewDelegate <NSObject>

- (void)alertView:(EXUAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface EXUAlertView : UIView

@property (nonatomic,weak) id<EXUAlertViewDelegate> delegate;

@property (nonatomic,readonly) NSArray<UIButton*> *buttons;

@property (nonatomic,assign) CGFloat buttonHeight;

@property (nonatomic,readonly) BOOL visible;

@property (nonatomic,weak) IBOutlet UIView *contentView;

@property (nonatomic,copy) void(^clickedButton)(NSInteger);

- (instancetype)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... ;

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

- (void)show;

- (void)dismiss;

+ (instancetype)currentAlertView;

@end
