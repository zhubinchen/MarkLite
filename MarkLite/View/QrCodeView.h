//
//  QrCodeView.h
//  MarkLite
//
//  Created by zhubch on 15/4/8.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QrCodeView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@end
