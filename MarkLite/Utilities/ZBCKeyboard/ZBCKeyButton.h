//
//  ZBCKeyButton.h
//  test
//
//  Created by Zhubch on 15-2-10.
//  Copyright (c) 2015年 Zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZBCKeyButton;

@protocol ZBCKeyButtonDelegate <NSObject>

- (void)pressedButton:(ZBCKeyButton*)button;

@end

@interface ZBCKeyButton : UIButton

@property (nonatomic,strong) NSString *imageName;

@property (nonatomic,strong) NSString *pressedImageName;

@property (nonatomic,strong) NSString *key;

@property (nonatomic,strong) UIColor *textColor;

@property (nonatomic,strong) UIColor *tintTextcolor;

@property (nonatomic,strong) UIColor *color;

@property (nonatomic,strong) UIColor *pressedColor;

@property (nonatomic,assign) BOOL upcase;

@property (nonatomic,assign) id<ZBCKeyButtonDelegate> delegate;

@end
