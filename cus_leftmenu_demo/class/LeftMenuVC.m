//
//  LeftMenuVC.m
//  cus_leftmenu_demo
//
//  Created by LiRui on 15/12/1.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import "LeftMenuVC.h"

//滑动方向  用于left_menu
typedef NS_ENUM(NSInteger,PanDirection){
    PanDirectionNone = 0,
    PanDirectionLeft = 1,
    PanDirectionRight = 2
};


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kAnimationDelay = 0.0f;
static const CGFloat kMaxBlackMaskAlpha = 0.8f;
static const CGFloat kMaxRightBlackMaskAlpha = 0.6f;



@interface LeftMenuVC()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIView *blackMask;
//pan 手势起始位置
@property(nonatomic,assign)CGPoint panOrigin;
@property(nonatomic,assign)BOOL animationInProgress;
@property(nonatomic,assign)CGFloat percentageOffsetFromLeft;
@property(nonatomic,strong)UIView * rightBlackMask;
@property(nonatomic,strong)UIPanGestureRecognizer* rightPanGesture;
@property(nonatomic)CGFloat maxRightX;

@end









@implementation LeftMenuVC

#pragma mark - init

-(instancetype)initWithLeftVC:(UIViewController *)leftVC rightVC:(UIViewController *)rightVC
{
    if (self = [super init]) {
        self.leftVC = leftVC;
        self.rightVC = rightVC;
        self.maxRightX = 320*0.8;
    }
    return self;
}

- (void) dealloc {
    _leftVC = nil;
    _rightVC = nil;
    _blackMask = nil;
}

#pragma mark - Load View
- (void) loadView {
    [super loadView];
    CGRect viewRect = [self viewBoundsWithOrientation:self.interfaceOrientation];
    self.view.backgroundColor =[UIColor blackColor];
    //初始化左侧VC
    UIViewController * leftViewcontroller = _leftVC;
    [leftViewcontroller willMoveToParentViewController:self];
    [self addChildViewController:leftViewcontroller];
    
    UIView * leftView = leftViewcontroller.view;
    leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    leftView.frame = viewRect;
    [self.view addSubview:leftView];
    
    
    //黑色浮层
    _blackMask = [[UIView alloc] initWithFrame:viewRect];
    _blackMask = nil;
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0;
    _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:_blackMask atIndex:0];
    
    
    _rightBlackMask = [[UIView alloc]initWithFrame:viewRect];
    _rightBlackMask.backgroundColor = [UIColor blackColor];
    _rightBlackMask.alpha = 0.0;
    _rightBlackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _rightBlackMask.userInteractionEnabled = YES;
    UITapGestureRecognizer * rightBlackMaskTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRightVC)];
    [_rightBlackMask addGestureRecognizer:rightBlackMaskTap];
    
    
    //初始化右侧VC
    UIViewController *rightViewController = _rightVC;
    [rightViewController willMoveToParentViewController:self];
    [self addChildViewController:rightViewController];
    
    UIView * rightView = rightViewController.view;
    rightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    rightView.frame = viewRect;
    [self.view addSubview:rightView];
    [rightViewController didMoveToParentViewController:self];
    [self addPanGestureToView:rightView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

#pragma mark - public

-(void)showRightVC
{
    if (_animationInProgress) {
        return;
    }
    [self rollBackViewController];
}

-(void)showLeftVC
{
    if (_animationInProgress) {
        return;
    }
    _animationInProgress = YES;
    
    UIViewController * vc = _rightVC;
    UIViewController * nvc = _leftVC;
    CGRect rect = CGRectMake(_maxRightX, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    [_rightVC.view addSubview:_rightBlackMask];
    
    [UIView animateWithDuration:0.3f delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        nvc.view.transform = CGAffineTransformScale(transf, 1.0f, 1.0f);
        vc.view.frame = rect;
        _blackMask.alpha = 0;
        _rightBlackMask.alpha = kMaxRightBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            _animationInProgress = NO;
        }
    }];
    
    [self handleRightProgress:1 withAnimation:YES withDuration:0.3f];

}

-(void)showRightVC:(UIViewController *)rightViewController Animation:(BOOL)animation
{
    if (_animationInProgress) {
        return;
    }
    _animationInProgress = YES;
    
    
    UIViewController * tmpVC = _rightVC;
    [tmpVC.view removeFromSuperview];
    [tmpVC removeFromParentViewController];
    
    
    _rightVC = rightViewController;
    rightViewController.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
    rightViewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _blackMask.alpha = 0.0;
    [rightViewController willMoveToParentViewController:self];
    _rightBlackMask.alpha = 0.0;
    [rightViewController.view addSubview:_rightBlackMask];
    [self addChildViewController:rightViewController];
    [self.view bringSubviewToFront:_blackMask];
    [self.view addSubview:rightViewController.view];
    [self addPanGestureToView:rightViewController.view];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        _leftVC.view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        rightViewController.view.frame = self.view.bounds;
        _blackMask.alpha = 0;
        _rightBlackMask.alpha = 0;
    }   completion:^(BOOL finished) {
        if (finished) {
            [rightViewController didMoveToParentViewController:self];
            _animationInProgress = NO;
            [_rightBlackMask removeFromSuperview];
            [self addPanGestureToView:rightViewController.view];
//            [_leftVC checkLeftMenuAndChangeSelect];
        }
    }];
    
    [self handleRightProgress:0 withAnimation:YES withDuration:0.3f];



}



#pragma mark - private

//手势结束后  最后滚动效果
- (void) rollBackViewController {
    _animationInProgress = YES;
    UIViewController * vc = _rightVC;
    UIViewController * nvc = _leftVC;
    CGRect rect = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    [UIView animateWithDuration:0.3f delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        nvc.view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        vc.view.frame = rect;
        _blackMask.alpha = kMaxBlackMaskAlpha;
        _rightBlackMask.alpha = 0;
    }   completion:^(BOOL finished) {
        if (finished) {
            _animationInProgress = NO;
            [_rightBlackMask removeFromSuperview];
        }
    }];
    
    [self handleRightProgress:0 withAnimation:YES withDuration:0.3f];
}





//pan 手势处理   action
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(_animationInProgress) return;
    CGPoint currentPoint = [panGesture translationInView:self.view];
    CGFloat x = currentPoint.x + _panOrigin.x;
    PanDirection panDirection = PanDirectionNone;
    CGPoint vel = [panGesture velocityInView:self.view];
    
    if (vel.x > 0) {
        panDirection = PanDirectionRight;
    } else {
        panDirection = PanDirectionLeft;
    }
    
    CGFloat offset = 0;
    
    UIViewController * vc ;
    vc = _rightVC;
    
    if(_rightBlackMask.superview != _rightVC.view){
        [_rightVC.view addSubview:_rightBlackMask];
    }
    
    offset = CGRectGetWidth(vc.view.frame) - x;
    
    _percentageOffsetFromLeft = offset/[self viewBoundsWithOrientation:self.interfaceOrientation].size.width;
    vc.view.frame = [self getSlidingRectWithPercentageOffset:_percentageOffsetFromLeft orientation:self.interfaceOrientation];
    //    [self transformAtPercentage:_percentageOffsetFromLeft];
    [self transformAtXMove:x];
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        // If velocity is greater than 100 the Execute the Completion base on pan direction
        if(fabsf(vel.x) > 100) {
            [self completeSlidingAnimationWithDirection:panDirection];
        }else {
            [self completeSlidingAnimationWithOffset:offset];
        }
    }
    
    CGFloat rightX = _rightVC.view.frame.origin.x;
    CGFloat progress = 0;
    if (rightX<10) {
        progress = 0;
    }else if (rightX>(_maxRightX-10)) {
        progress = 1;
    }else{
        progress = (rightX-10)/(_maxRightX-20);
    }
    [self handleRightProgress:progress withAnimation:NO withDuration:0];
    
}


//滑动进度传递到right VC 页面
-(void)handleRightProgress:(CGFloat)progress withAnimation:(BOOL)animation withDuration:(CGFloat)duration{
    
//    if ([_rightVC isKindOfClass:[CustomAnimationNav class]]) {
//        
//        CustomAnimationNav * customAnimationNav = (CustomAnimationNav *)_rightVC;
//        UIViewController * rootVC = [customAnimationNav getRootVC];
//        if ([rootVC respondsToSelector:@selector(leftMenuButton)] && [rootVC respondsToSelector:@selector(showLeftMenuButtonWithProgress:WithDuration:WithAnimation:)]) {
//            [rootVC showLeftMenuButtonWithProgress:progress WithDuration:duration WithAnimation:animation];
//        }
//    }
}





// 添加pan gesture
- (void) addPanGestureToView:(UIView*)view
{
    if (_rightPanGesture) {
        [_rightVC.view removeGestureRecognizer:_rightPanGesture];
        _rightPanGesture = nil;
    }
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(gestureRecognizerDidPan:)];
    
    panGesture.cancelsTouchesInView = YES;
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    [view addGestureRecognizer:panGesture];
    _rightPanGesture = panGesture;
    panGesture = nil;
}


#pragma mark - private  frame-
//--frame---------------------------------------------------------------------------------------------
//获取主页面的大小 Get the size of view in the main screen
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation{
    CGRect bounds = [UIScreen mainScreen].bounds;
    if([[UIApplication sharedApplication]isStatusBarHidden]){
        return bounds;
    } else if(UIInterfaceOrientationIsLandscape(orientation)){
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))  {
            bounds.size.height = width - 20;
        }else {
            bounds.size.height = width;
        }
        return bounds;
    }else{
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))  {
            bounds.size.height-=20;
        }
        return bounds;
    }
}


// Get the origin and size of the visible viewcontrollers(child)
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation {
    CGRect viewRect = [self viewBoundsWithOrientation:orientation];
    CGRect rectToReturn = CGRectZero;
    rectToReturn.size = viewRect.size;
    rectToReturn.origin = CGPointMake(MAX(0,(1-percentage)*viewRect.size.width), 0.0);
    return rectToReturn;
}


// 处理缩放还有 黑色透明度
// Set the required transformation based on percentage
- (void) transformAtXMove:(CGFloat)x{
    CGAffineTransform transf = CGAffineTransformIdentity;
    CGFloat percentage = (_maxRightX-x)/_maxRightX;
    if (percentage<0) {
        percentage = 0;
    }
    CGFloat newTransformValue =  1 - (percentage*10)/100;
    CGFloat newAlphaValue = percentage* kMaxBlackMaskAlpha;
    _leftVC.view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
    _blackMask.alpha = newAlphaValue;
    _rightBlackMask.alpha = (1-percentage)*kMaxRightBlackMaskAlpha;
}


// 处理缩放还有 黑色透明度
// Set the required transformation based on percentage
- (void) transformAtPercentage:(CGFloat)percentage {
    CGAffineTransform transf = CGAffineTransformIdentity;
    CGFloat newTransformValue =  1 - (percentage*10)/100;
    CGFloat newAlphaValue = percentage* kMaxBlackMaskAlpha;
    _leftVC.view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
    _blackMask.alpha = newAlphaValue;
}

#pragma mark - This will complete the animation base on pan direction
//完成
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction {
    if(direction==PanDirectionRight){
        [self showLeftVC];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - This will complete the animation base on offset
//
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset{
    
    if(offset<[self viewBoundsWithOrientation:self.interfaceOrientation].size.width/2) {
        [self showLeftVC];
    }else {
        [self rollBackViewController];
    }
}



#pragma mark -delegate-
//pan 手势delegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    return fabs(translation.x) > fabs(translation.y) ;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    UIViewController * vc =  _rightVC;
    //    if (vc.needNotHandlePanGestureRecognizer) {
    //        return NO;
    //    }
    
    //多余一个手指的手势不再处理
    if(gestureRecognizer.numberOfTouches>0){
        return NO;
    }
    
    _panOrigin = vc.view.frame.origin;
    gestureRecognizer.enabled = YES;
    return !_animationInProgress;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    //    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
    //        UIScrollView * scrollView = (UIScrollView *)otherGestureRecognizer.view;
    //        if (scrollView.contentOffset.x == 0) {
    //            return YES;
    //        }
    //    }
    return NO;
}




@end
