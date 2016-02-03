//
//  SplitViewController.m
//  MarkLite
//
//  Created by zhubch on 1/25/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "SplitViewController.h"
#import "EditViewController.h"

@interface SplitViewController () <UISplitViewControllerDelegate>

@end

@implementation SplitViewController
{
    UIPopoverController *popVc;
    EditViewController *editVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    // Do any additional setup after loading the view.
}

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc
{
    return UISplitViewControllerDisplayModePrimaryHidden;
}

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
//    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
//        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(pop)];
//        editVc =  [(UINavigationController*)self.viewControllers[1] viewControllers][0];
//        editVc.navigationItem.leftBarButtonItem = item;
//    }else{
//        editVc =  [(UINavigationController*)self.viewControllers[1] viewControllers][0];
//        editVc.navigationItem.leftBarButtonItem = nil;
//    }
//}
//
//- (void)pop{
//    if (popVc == nil) {
//        popVc = [[UIPopoverController alloc]initWithContentViewController:self.viewControllers[0]];
//    }
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
