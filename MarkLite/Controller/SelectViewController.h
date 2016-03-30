//
//  SelectViewController.h
//  MarkLite
//
//  Created by zhubch on 3/30/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectViewController : UIViewController

@property(nonatomic,strong) NSArray *selectOptions;

@property(nonatomic,copy) void(^didSelected)(int index);

@end
