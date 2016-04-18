//
//  FileOperationCell.m
//  MarkLite
//
//  Created by zhubch on 4/18/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "FileOperationCell.h"

@implementation FileOperationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorWithRGBString:@"f0f2f4"];
    }
    return self;
}

- (void)setWidth:(CGFloat)width
{
    NSArray *imgNames = @[@"delete",@"rename",@"export"];
    NSArray *titles = @[@"删除",@"重命名",@"导出"];
    
    CGFloat w = width / 4.0;
    for (int i = 0; i < imgNames.count; i++) {
        UIView *v = [[UIView alloc]initWithFrame:CGRectMake(i * w + w, 0, w, 60)];
        [self addSubview:v];
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(w*0.5 - 17.5, 0, 35, 35)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:imgNames[i]] forState:UIControlStateNormal];
        [v addSubview:btn];
        
        btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 35, w, 15)];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:kThemeColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [v addSubview:btn];
    }
}

- (void)clickedButton:(UIButton*)sender
{
    if (sender.tag == 0) {
        self.deleteFileBlock(self.item);
    }else if (sender.tag == 1){
        self.renameFileBlock(self.item);
    }else{
        self.exportBlock(self.item);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
