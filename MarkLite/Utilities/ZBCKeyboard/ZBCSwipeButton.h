//
//  ZBCSwipeButton.h
//  test
//
//  Created  by Zhubch on 15-2-11.
//  Copyright (c) 2015年 Zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZBCSwipeButton;

@protocol ZBCSwipeButtonDelegate <NSObject>

- (void)choosedKey:(NSString*)key;

@end

/**
 *  可根据滑动方向识别哪个键。直接点判定为中间的键
 */
@interface ZBCSwipeButton : UIView

@property (nonatomic,assign) int tintIndex;

@property (nonatomic,strong) UIColor *textColor;

@property (nonatomic,strong) UIColor *pressedTextColor;

@property (nonatomic,strong) UIColor *tintTextcolor;

@property (nonatomic,strong) UIColor *color;

@property (nonatomic,strong) UIColor *pressedColor;

@property (nonatomic,strong) NSString *keys;

@property (nonatomic,assign) id<ZBCSwipeButtonDelegate> delegate;

@end
