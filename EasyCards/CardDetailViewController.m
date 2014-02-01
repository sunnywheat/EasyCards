//
//  CardDetailViewController.m
//  EasyCards
//
//  Created by Paul Wong on 2/1/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import "CardDetailViewController.h"
#import "MyCardsViewController.h"

@interface CardDetailViewController ()

@end

@implementation CardDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.gestureButton addTarget:self action:@selector(sendCard) forControlEvents:UIControlEventTouchUpInside];
    self.gestureButton.hidden = NO;
}

- (void)sendCard
{
    // Start transmitting card ID information
    
    // Start animating (moving out of the screen)
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    theAnimation.duration=1;
    theAnimation.fromValue=[NSNumber numberWithFloat:0];
    theAnimation.toValue=[NSNumber numberWithFloat:-568];
    theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    
    [self.backgroundView.layer addAnimation:theAnimation forKey:@"translation.y"];
    
    // gestureButton is hidden
    self.gestureButton.hidden = YES;
    
    [self performSelector:@selector(dismiss) withObject:self afterDelay:1.5f];
}

/*
- (BOOL)prefersStatusBarHidden
{
    return NO;
}
*/

- (void)dismiss
{
    // navbar, tabbar, statusbar should be revealed after sending
    // UINavigationController *navigationController = (UINavigationController *)self.parentViewController;
    // navigationController.navigationBarHidden = NO;
    // MyCardsViewController *controller = (MyCardsViewController *)navigationController.topViewController;
    // controller.tabBarController.tabBar.hidden = NO;
    // [self setNeedsStatusBarAppearanceUpdate];
    
    [self dismissFromParentViewController];
}

- (void)dismissFromParentViewController
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)presentInParentViewController:(UIViewController *)parentViewController
{
    
    [parentViewController.view.superview addSubview:self.view];
    [parentViewController.navigationController addChildViewController:self];
 
    // Add animation here!!!  :)
    
    // Animation for the card popping up and rotating and scaling
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:-0.5*M_PI];
    rotateAnimation.duration = 1.0f;
    // CABasicAnimation default duration is 0.25 second if not specified...
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    UIView *backgroundView = self.backgroundView;
    
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;

    [backgroundView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.7f];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.3f];
    scaleAnimation.duration = 1.0f;
    
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    
    [backgroundView.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    
    
    [backgroundView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    
    // Animation for the gesture view
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    opacityAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    opacityAnimation.duration = 2.0f;
    [self.gestureButton.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
    
    
    [self didMoveToParentViewController:parentViewController];
}

@end
