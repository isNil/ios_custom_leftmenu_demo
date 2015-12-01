//
//  LeftMenuVC.h
//  cus_leftmenu_demo
//
//  Created by LiRui on 15/12/1.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+LeftMenuVC.h"

@interface LeftMenuVC : UIViewController

@property(nonatomic,strong)UIViewController * leftVC;
@property(nonatomic,strong)UIViewController * rightVC;


-(instancetype)initWithLeftVC:(UIViewController *)leftVC rightVC:(UIViewController *)rightVC;

-(void)showRightVC;

-(void)showLeftVC;

-(void)showRightVC:(UIViewController *)rightViewController Animation:(BOOL)animation;


@end
