//
//  ImageViewController.m
//  MarkLite
//
//  Created by Bingcheng on 6/27/16.
//  Copyright © 2016 Bingcheng. All rights reserved.
//

#import "ImageViewController.h"
#import "Configure.h"

@interface ImageViewController ()

@property (nonatomic,weak) IBOutlet UILabel *tipsLable;
@property (nonatomic,weak) IBOutlet UILabel *lowLable;
@property (nonatomic,weak) IBOutlet UILabel *highLable;
@property (nonatomic,weak) IBOutlet UISlider *slider;
@property (nonatomic,weak) IBOutlet UIView *view2;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.slider.value = [Configure sharedConfigure].imageResolution;
    _tipsLable.text = ZHLS(@"ImageResolutionTips");
    _lowLable.text = ZHLS(@"Low");
    _highLable.text = ZHLS(@"High");
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@",[self allLableOnView:self.view]);
    NSLog(@"%@",[self connectedLable]);
    
    NSMutableArray *allLable = [self allLableOnView:self.view];
    NSArray *connectedLable = [self connectedLable];
    
    [allLable removeObjectsInArray:connectedLable];
    
//    for (UILabel *l in allLable) {
//        l.font = [UIFont boldSystemFontOfSize:24];
//    }
}

- (NSMutableArray*)allLableOnView:(UIView*)parent
{
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *v in parent.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            [array addObject:v];
        }
        
        [array addObjectsFromArray:[self allLableOnView:v]];
    }
    return array;
}

- (NSArray*)connectedLable
{
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(self.class, &count);
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        
        SEL selector = NSSelectorFromString([NSString stringWithUTF8String:propertyName]);
        IMP imp = [self methodForSelector:selector];
        id (*func)(id, SEL) = (void *)imp;
        id value = func(self, selector);
        
        if ([value isKindOfClass:[UILabel class]]) {
            [valueArray addObject:value];
        }
    }
    
    free(properties);
    return valueArray;
}

- (void)viewDidLayoutSubviews
{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
    
    line = [[UIView alloc]initWithFrame:CGRectMake(0, 74.5, self.view.bounds.size.width, 0.3)];
    line.backgroundColor = [UIColor lightGrayColor];
    [_view2 addSubview:line];
}

/*
 图床
 创建笔记
 共享为PDF或Web页面
 iCloud同步
 导出到印象笔记*/
- (IBAction)compressionQualityChanged:(UISlider*)sender{
    [Configure sharedConfigure].imageResolution = sender.value;
}

@end
