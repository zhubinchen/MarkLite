//
//  EditViewController.h
//  MarkLite
//
//  Created by zhubch on 15-3-31.
//  Copyright (c) 2016年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditView.h"

@interface EditViewController : UIViewController

@property (nonatomic,weak) IBOutlet EditView *editView;

@property (nonatomic,weak) UIViewController *projectVc;

@end

