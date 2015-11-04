//
//  EditView.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "EditView.h"
#import "ZBCKeyBoard.h"

@implementation EditView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        if (!kIsPhone) {
            _keyboard = [[ZBCKeyBoard alloc]init];
            _keyboard.editView = self;
            self.inputView = _keyboard;
            self.spellCheckingType =  UITextSpellCheckingTypeNo;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
            self.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.inputAccessoryView = nil;
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *) coder {
    if (self = [super initWithCoder:coder]) {
        if (!kIsPhone) {
            _keyboard = [[ZBCKeyBoard alloc]init];
            _keyboard.editView = self;
            self.inputView = _keyboard;
            self.spellCheckingType =  UITextSpellCheckingTypeNo;
            self.autocorrectionType = UITextAutocorrectionTypeNo;
            self.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.inputAccessoryView = nil;
        }
    }
    return self;
}

@end
