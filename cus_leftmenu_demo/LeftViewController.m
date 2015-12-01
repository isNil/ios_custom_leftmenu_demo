//
//  LeftViewController.m
//  cus_leftmenu_demo
//
//  Created by LiRui on 15/12/1.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import "LeftViewController.h"
#import "LeftMenuVC.h"

@implementation LeftViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"left menu vc" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    


}

-(void)click
{
    [self.menuVC showRightVC];


}



@end
