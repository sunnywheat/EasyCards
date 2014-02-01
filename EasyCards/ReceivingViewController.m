//
//  ReceivingViewController.m
//  EasyCards
//
//  Created by Paul Wong on 1/31/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import "ReceivingViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import <Parse/Parse.h>

@interface ReceivingViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData         *data;

@end

@implementation ReceivingViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.backgroundView.hidden = YES;
    
    // Start up the CBCentralManager
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // And somewhere to store the incoming data
    _data = [[NSMutableData alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    [super viewWillDisappear:animated];
}

#pragma mark - Central Methods

/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    [self scan];
    
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    /*
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -35) {
        return;
    }
    */
    
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    if (RSSI.integerValue < -105) {
        return;
    }
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    // Ok, it's in range - have we already seen it?
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        // We have, so show the data,
        // [self.textview setText:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
        NSLog(@"Received Info Text: %@", [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]);
        
        NSString *objectIdReceived = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        // This is when objectId is fully received, now is the time to pull from Parse and make some cool animation!
        PFQuery *query = [PFQuery queryWithClassName:@"Card"];
        [query getObjectInBackgroundWithId:objectIdReceived block:^(PFObject *card, NSError *error) {
            
            UIImageView *backgroundImageView = (UIImageView *)[self.view viewWithTag:1000];
            UIImageView *profileImageView = (UIImageView *)[self.view viewWithTag:1001];
            
            UILabel *nameLabel = (UILabel *)[self.view viewWithTag:2001];
            UILabel *descriptionLabel = (UILabel *)[self.view viewWithTag:2002];
            UILabel *phoneLabel = (UILabel *)[self.view viewWithTag:2003];
            UILabel *twitterLabel = (UILabel *)[self.view viewWithTag:2004];
            UILabel *emailLabel = (UILabel *)[self.view viewWithTag:2005];
            UILabel *addressLineOneLabel = (UILabel *)[self.view viewWithTag:2006];
            UILabel *addressLineTwoLabel = (UILabel *)[self.view viewWithTag:2007];
            
            NSString *cardDataStr = [card objectForKey:@"cardDataStr"];
            NSArray *cardDataArr = [cardDataStr componentsSeparatedByString:@"#&"];
            
            PFFile *profileImgViewFile = [card objectForKey:@"profileImg"];
            [profileImgViewFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *profileImage = [UIImage imageWithData:data];
                    
                    
                    PFFile *backgroundImgFile = [card objectForKey:@"backgroundImg"];
                    [backgroundImgFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            
                            UIImage *backgroundImage = [UIImage imageWithData:data];
                            
                            backgroundImageView.image = backgroundImage;
                            profileImageView.image = profileImage;
                            nameLabel.text = cardDataArr[0];
                            descriptionLabel.text = cardDataArr[1];
                            phoneLabel.text = cardDataArr[2];
                            twitterLabel.text = cardDataArr[3];
                            emailLabel.text = cardDataArr[4];
                            addressLineOneLabel.text = cardDataArr[5];
                            addressLineTwoLabel.text = cardDataArr[6];
                            
                            self.backgroundView.hidden = NO;
                            
                            // Add animation
                            
                            /*
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
                             
                            [self.backgroundView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
                            
                             
                             
                            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                            scaleAnimation.fromValue = [NSNumber numberWithFloat:0.7f];
                            scaleAnimation.toValue = [NSNumber numberWithFloat:1.3f];
                            scaleAnimation.duration = 1.0f;
                            
                            scaleAnimation.removedOnCompletion = NO;
                            scaleAnimation.fillMode = kCAFillModeForwards;
                            
                            [self.backgroundView.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
                            */
                            
                            // Start animating (moving out of the screen)
                            CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
                            theAnimation.duration=1;
                            theAnimation.fromValue=[NSNumber numberWithFloat:-568];
                            theAnimation.toValue=[NSNumber numberWithFloat:0];
                            theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                            theAnimation.removedOnCompletion = NO;
                            theAnimation.fillMode = kCAFillModeForwards;
                            
                            [self.backgroundView.layer addAnimation:theAnimation forKey:@"translation.y"];
                            
                            CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                            rotateAnimation.fromValue = [NSNumber numberWithFloat:-0.5*M_PI];
                            rotateAnimation.toValue = [NSNumber numberWithFloat:-0.5*M_PI];
                            rotateAnimation.duration = 1.0f;
                            // CABasicAnimation default duration is 0.25 second if not specified...
                            rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                            
                            rotateAnimation.removedOnCompletion = NO;
                            rotateAnimation.fillMode = kCAFillModeForwards;
                            
                            [self.backgroundView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
                            
                            
                            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                            scaleAnimation.fromValue = [NSNumber numberWithFloat:2.0f];
                            scaleAnimation.toValue = [NSNumber numberWithFloat:1.3f];
                            scaleAnimation.duration = 1.0f;
                            
                            scaleAnimation.removedOnCompletion = NO;
                            scaleAnimation.fillMode = kCAFillModeForwards;
                            
                            [self.backgroundView.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
                            
                            // Store in NSUserDefaults receivedObjectIds
                            
                            self.allReceivedCardIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AllReceivedCardIDs"] mutableCopy];
                            if (self.allReceivedCardIDs == nil) {
                                self.allReceivedCardIDs = [[NSMutableArray alloc] init];
                            }
                            [self.allReceivedCardIDs insertObject:objectIdReceived atIndex:0];
                            [[NSUserDefaults standardUserDefaults] setObject:self.allReceivedCardIDs forKey:@"AllReceivedCardIDs"];
                            
                            
                            [self performSelector:@selector(rotateAndShrink) withObject:self afterDelay:3.0f];
                            
                            
                            
                            
                            // Deal with Collection of Cards displaying!!!
                            
                        }
                    }];
                    
                }
            }];
            

            
        }];
        
        // Cancel our subscription to the characteristic
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    // Otherwise, just add the data on to what we already have
    [self.data appendData:characteristic.value];
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
}

- (void)rotateAndShrink
{
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:-0.5*M_PI];
    rotateAnimation.toValue = [NSNumber numberWithFloat:0];
    rotateAnimation.duration = 1.0f;
    // CABasicAnimation default duration is 0.25 second if not specified...
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    
    [self.backgroundView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    

    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.3f];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    scaleAnimation.duration = 1.0f;
    
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    [self.backgroundView.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];

    
    NSLog(@"transfer is complete!");
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    
    // We're disconnected, so start scanning again
    // [self scan];
}


/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (!(self.discoveredPeripheral.state == CBPeripheralStateConnected)) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}

@end
