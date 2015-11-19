//
//  KeyboardBar.m
//  MarkLite
//
//  Created by zhubch on 11/10/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "KeyboardBar.h"

@implementation KeyboardBar

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self createItem];
    return self;
}

- (void)createItem
{
    UIColor *titleColor = [UIColor colorWithRGBString:@"3498db"];
    NSArray *titles = @[@"Tab",@"add_link",@"add_image",@"#",@"*",@"-",@"<",@">",@"/",@"`",@"!",@"|"];
    CGFloat w = (kScreenWidth-10) / (titles.count - 1);

    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tintColor = [UIColor blueColor];
        btn.tag = i;
        btn.frame = CGRectMake(7.5+i*((kScreenWidth-40) / (titles.count - 1)), 5, w-5, w-5);
        if (i == 0) {
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
        }else if (i < 3) {
            [btn setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
            [btn setImage:[UIImage imageNamed:titles[i]] forState:UIControlStateNormal];
        }else{
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:titleColor forState:UIControlStateNormal];
        }
        [btn showBorderWithColor:titleColor radius:3 width:1];
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

- (void)itemClicked:(UIButton*)btn
{
    if (btn.tag == 0) {
        [_editView insertText:@"\t"];
    }else if (btn.tag > 3) {
        [_editView insertText:btn.currentTitle];
    }else if (btn.tag == 1){
        if (SYSTEM_VERSION >= 8.0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加链接" message:@"请输入链接" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *name = alert.textFields[0].text;
                if (name.length < 1) {
                    return ;
                }
                NSString *text = [NSString stringWithFormat:@"[](%@)",name];
                [_editView insertText:text];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            [self.vc presentViewController:alert animated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加链接" message:@"请输入链接" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alert){
                if (buttonIndex == 1) {
                    [[alert textFieldAtIndex:0] resignFirstResponder];
                }
                NSString *name = [alert textFieldAtIndex:0].text;
                NSString *text = [NSString stringWithFormat:@"[](%@)",name];
                [_editView insertText:text];
            };
            [alert show];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
