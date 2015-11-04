//
//  ZBCKeyButton.m
//  test
//
//  Created by Zhubch on 15-2-10.
//  Copyright (c) 2015年 Zhubch. All rights reserved.
//

#import "ZBCKeyButton.h"

@implementation ZBCKeyButton

- (instancetype)init
{
    if (self = [super init]) {
        self.titleLabel.font = [UIFont systemFontOfSize:30];
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}


- (void)setUpcase:(BOOL)upcase
{
    _upcase = upcase;
    if (upcase){
        [self setTitle:_key.uppercaseString forState:UIControlStateNormal];
    } else {
        [self setTitle:_key.lowercaseString forState:UIControlStateNormal];
    }
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)setPressedImageName:(NSString *)pressedImageName
{
    _pressedImageName = pressedImageName;
    [self setImage:[UIImage imageNamed:pressedImageName] forState:UIControlStateHighlighted];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.backgroundColor = color;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)setTintTextcolor:(UIColor *)tintTextcolor
{
    _tintTextcolor = tintTextcolor;
    [self setTitleColor:tintTextcolor forState:UIControlStateHighlighted];
}

- (void)touchDown
{
    self.backgroundColor = _pressedColor;
}

- (void)touchUpInside
{
    self.backgroundColor = _color;
    [self.delegate pressedButton:self];
}

- (void)touchUp
{
    self.backgroundColor = _color;
}

@end
