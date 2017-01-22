//
//  EditViewController.h
//  MarkLite
//
//  Created by Bingcheng on 15-3-31.
//  Copyright (c) 2016年 Bingcheng. All rights reserved.
//

#import "BaseViewController.h"
#import "EditView.h"
#import "RenderView.h"

@interface EditViewController : BaseViewController

@property (nonatomic,weak) IBOutlet EditView *editView;
@property (nonatomic,weak) IBOutlet RenderView *renderView;

@property (nonatomic,weak) UIViewController *projectVc;

@end

