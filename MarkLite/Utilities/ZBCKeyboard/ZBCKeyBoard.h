//
//  ZBCKeyBoard.h
//  test
//
//  Created by Zhubch on 15-2-10.
//  Copyright (c) 2015年 Zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZBCKeyBoardStyleFlat,//扁平
    ZBCKeyBoardStyleColorfull,//炫彩
    ZBCKeyBoardStyleSimulate//拟物
} ZBCKeyBoardStyle;

static const NSUInteger ZBCKeyBoardStyleDefault = ZBCKeyBoardStyleFlat;

@interface ZBCKeyBoard : UIView

@property (nonatomic,assign) id<UIKeyInput> editView;

@property (nonatomic,assign) ZBCKeyBoardStyle style;

@property (nonatomic,strong) UIImage *backgroundImage;//只有当style设置为炫彩风格才有效

@end
