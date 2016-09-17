//
//  SortOptionsView.m
//  MarkLite
//
//  Created by zhubch on 7/21/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "SortOptionsView.h"

@implementation SortOptionsView
{
    UIImageView *checkImgView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGFloat w = self.bounds.size.width;

        self.backgroundColor = [UIColor whiteColor];
        [self showShadowWithColor:[UIColor grayColor] offset:CGSizeMake(0, 5)];
        
        NSArray *options = @[ZHLS(@"SortByName"),ZHLS(@"SortByCreateTime"),ZHLS(@"SortByUpdateTime")];
        for (int i = 0; i < options.count; i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20, i*30, w - 20, 30)];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.tag = i;
            [btn addTarget:self action:@selector(choosedOption:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:options[i] forState:UIControlStateNormal];
            [btn setTitleColor:kTintColor forState:UIControlStateNormal];
            [self addSubview:btn];
        }
        
        checkImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"check"]];
        [self addSubview:checkImgView];
    }
    
    return self;
}

- (void)setCurrentSortOption:(NSInteger)currentSortOption
{
    _currentSortOption = currentSortOption;
    CGFloat w = self.bounds.size.width;
    checkImgView.frame = CGRectMake(w - 35, _currentSortOption*30 + 3, 24, 24);
}

- (void)choosedOption:(UIButton*)optionBtn
{
    self.currentSortOption = optionBtn.tag;
    _choosedIndex(optionBtn.tag);
}

@end
