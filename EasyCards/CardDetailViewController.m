//
//  CardDetailViewController.m
//  EasyCards
//
//  Created by Paul Wong on 2/1/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import "CardDetailViewController.h"
#import "MyCardsViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CardDetailViewController () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end

#define NOTIFY_MTU      100

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
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    
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
    
    // Animation for the gesture view
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    opacityAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    opacityAnimation.duration = 2.0f;
    [self.gestureButton.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
    
    
    [self didMoveToParentViewController:parentViewController];
}

// Everything below contributes to info sharing over bluetooth!  :)
/*
 
 SMART INTEGRATION WITH APPLE'S EXAMPLE CODE!!!  :)
 
 */

#pragma mark - View Lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    [self.peripheralManager stopAdvertising];
    
    [super viewWillDisappear:animated];
}

#pragma mark - Peripheral Methods

/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    /* Send Text */
    // Get the data for text
    NSString *objectIdToBroadcast = self.objectIdToBroadcast;
    self.dataToSend = [objectIdToBroadcast dataUsingEncoding:NSUTF8StringEncoding];
    
    
    /* Send Image
     // Get the data for image
     NSData *imageData = UIImageJPEGRepresentation([self.imageView image], 0.0);
     self.dataToSend = imageData;
     */
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    [self sendData];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // If sending just text, NOTIFY_MTU is 20
    // If sending image/other files, NOTIFY_MTU is 2000
    // No, 2000 is too large, there is actually limit on characteristic value that can be conveyed each time, from what I see from the console, only 176 characters from characteristic value is received on iPod side!  :)
    // So if sending image/other files, NOTIFY_MTU is 100
    
    
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        // Encoding string for Text Data
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        
        // Encoding string for Image Data
        // NSString *stringFromData = [GTMBase64 stringByEncodingData:chunk];
        
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}

@end
