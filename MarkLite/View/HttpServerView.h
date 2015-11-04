//
//  HttpServerView.h
//  MarkLite
//
//  Created by zhubch on 15/4/8.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HttpServerView : UIView
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UISwitch *openSwitch;
@end
