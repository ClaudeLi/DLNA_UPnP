//
//  CLViewController.m
//  DLNA_UPnP
//
//  Created by ClaudeLi on 04/12/2019.
//  Copyright (c) 2019 ClaudeLi. All rights reserved.
//

#import "CLViewController.h"
#import "CLSearchDeviceController.h"

@interface CLViewController ()

@end

@implementation CLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton* button = [UIButton new];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@" 搜索设备 " forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button sizeToFit];
    button.center = self.view.center;
}

- (void)clickButtonAction{
    CLSearchDeviceController *search = [[CLSearchDeviceController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
