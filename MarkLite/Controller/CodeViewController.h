//
//  CodeViewController.h
//  MarkLite
//
//  Created by zhubch on 15-3-31.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditView.h"

@class ProjectViewController;

@interface CodeViewController : UIViewController

@property (nonatomic,weak) IBOutlet EditView *editView;

@property (nonatomic,weak) ProjectViewController *projectVc;

@end

