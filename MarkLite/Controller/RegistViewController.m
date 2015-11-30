//
//  RegistViewController.m
//  MarkLite
//
//  Created by zhubch on 11/25/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "RegistViewController.h"
#import "User.h"
#import "HttpRequest.h"

@interface RegistViewController ()
@property (nonatomic,weak) IBOutlet UITextField *nameField;
@property (nonatomic,weak) IBOutlet UITextField *pswdField;
@property (nonatomic,weak) IBOutlet UITextField *pswdRepeatField;
@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)regist:(id)sender
{
    [self beginLoadingAnimation:@"正在注册..."];
    User *user = [User currentUser];
    user.account = _nameField.text;
    user.password = _pswdField.text;
    user.name = _nameField.text;
    
    NSDictionary *body = @{@"email":user.account,@"password":user.password,@"name":user.name};
    [HttpRequest postWithUrl:@"http://192.168.1.83/AddressBook/api/regist.php" Body:body Succese:^(NSData *response) {
        NSDictionary *dic = response.toDictionay;
        if ([dic[@"code"] intValue] == 0) {
            [user setValuesForKeysWithDictionary:body];
            user.hasLogin = YES;
            [user archive];
            [self performSegueWithIdentifier:@"main" sender:self];
        }else{
            [self showToast:@"注册失败"];
        }
        [self stopLoadingAnimation];
    } Failed:^(ErrorCode code) {
        [self stopLoadingAnimation];
        [self showToast:@"网络异常"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
