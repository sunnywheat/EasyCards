//
//  CardDetailViewController.h
//  EasyCards
//
//  Created by Paul Wong on 2/1/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransferService.h"

@interface CardDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIButton *gestureButton;

@property (strong, nonatomic) NSString *objectIdToBroadcast;


- (void)presentInParentViewController:(UIViewController *)parentViewController;


@end
