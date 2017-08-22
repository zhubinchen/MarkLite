//
//  UIView + Localizations.m
//  zbd
//
//  Created by zhubch on 2017/7/31.
//  Copyright © 2017年 zbd. All rights reserved.
//

#import "LocalizationsExtension.h"
#import <objc/runtime.h>

#define kIgnoreTag 4654

@implementation UILabel(MarkLite)

+ (void)load {
//    Method origMethod = class_getInstanceMethod([self class],@selector(awakeFromNib));
//    Method swizMethod = class_getInstanceMethod([self class],@selector(zbc_awakeFromNib));
//    method_exchangeImplementations(origMethod, swizMethod);
}

- (void)zbc_awakeFromNib {
    [self zbc_awakeFromNib];
    if (self.tag != kIgnoreTag) {
        self.text = NSLocalizedString(self.text, "");
    }
}

@end

@implementation UIButton(MarkLite)

+ (void)load {

//    Method origMethod = class_getInstanceMethod([self class],@selector(awakeFromNib));
//    Method swizMethod = class_getInstanceMethod([self class],@selector(zbc_awakeFromNib));
//    method_exchangeImplementations(origMethod, swizMethod);
}

- (void)zbc_awakeFromNib {
    [self zbc_awakeFromNib];
    if (self.tag != kIgnoreTag) {
        
        [self setTitle:NSLocalizedString([self titleForState:UIControlStateNormal],"") forState:UIControlStateNormal];
        [self setTitle:NSLocalizedString([self titleForState:UIControlStateDisabled],"") forState:UIControlStateDisabled];
        [self setTitle:NSLocalizedString([self titleForState:UIControlStateSelected],"") forState:UIControlStateSelected];
    }
}

@end
