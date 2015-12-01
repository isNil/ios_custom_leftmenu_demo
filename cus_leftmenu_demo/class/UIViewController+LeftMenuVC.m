//
//  UIViewController+LeftMenuVC.m
//  cus_leftmenu_demo
//
//  Created by LiRui on 15/12/1.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import "UIViewController+LeftMenuVC.h"
#import "LeftMenuVC.h"

@implementation UIViewController (LeftMenuVC)


-(LeftMenuVC *)menuVC{
    
    if ([self.parentViewController isKindOfClass:[LeftMenuVC class]]) {
        return (LeftMenuVC *)self.parentViewController;
    }else if([self.parentViewController.parentViewController isKindOfClass:[LeftMenuVC class]]){
        return (LeftMenuVC *)self.parentViewController.parentViewController;
    }
    return nil;
}






@end
