//
//  LoginViewController.m
//  MarkLite
//
//  Created by zhubch on 11/25/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "HttpRequest.h"

@interface LoginViewController ()
@property (nonatomic,weak) IBOutlet UITextField *nameField;
@property (nonatomic,weak) IBOutlet UITextField *pswdField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    if ([User currentUser].hasLogin) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        UIViewController *vc = [board instantiateViewControllerWithIdentifier:@"main_tab"];
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (IBAction)login:(id)sender
{
    [self beginLoadingAnimation:@"正在登录..."];
    User *user = [User currentUser];
    user.account = _nameField.text;
    user.password = _pswdField.text;
    
    NSDictionary *body = @{@"email":user.account,@"password":user.password};
    [HttpRequest postWithUrl:@"http://192.168.1.92/AddressBook/api/login.php" Body:body Succese:^(NSData *response) {
        NSDictionary *dic = response.toDictionay;
        if ([dic[@"code"] intValue] == 0) {
            [user setValuesForKeysWithDictionary:body];
            user.hasLogin = YES;
            [user archive];
            [self performSegueWithIdentifier:@"main" sender:self];
        }else{
            [self showToast:@"请检查账号和密码是否正确"];
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
