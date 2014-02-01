//
//  MyCardsViewController.m
//  EasyCards
//
//  Created by Paul Wong on 1/31/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import "MyCardsViewController.h"
#import "UIImage+Resize.h"
#import "AddCardViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"
#import <Parse/Parse.h>

@interface MyCardsViewController () <CBPeripheralManagerDelegate>
{
    NSString *categoryToPass;
}

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@end

#define NOTIFY_MTU      100

@implementation MyCardsViewController

- (IBAction)addCard:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Card Category" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Personal", @"Business", nil];
    [actionSheet showInView:self.view.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Personal
        categoryToPass = @"Personal";
        [self performSegueWithIdentifier:@"addCard" sender:self];
    } else if (buttonIndex == 1) {
        // Business
        categoryToPass = @"Business";
        [self performSegueWithIdentifier:@"addCard" sender:self];
    } else if (buttonIndex == 2) {
        // Cancel
        // Do nothing...
        categoryToPass = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addCard"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        AddCardViewController *controller = (AddCardViewController *)navigationController.topViewController;
        controller.cardCategory = categoryToPass;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.separatorColor = [UIColor clearColor];
    
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    // [self.peripheralManager stopAdvertising];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Templates";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:2000];
    
    UIImageView *backgroundImageView = (UIImageView *)[cell viewWithTag:1000];
    backgroundImageView.layer.cornerRadius = 4.0f;
    backgroundImageView.layer.masksToBounds = YES;
    
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:1001];
    
    if (indexPath.section == 0) {
        // "templates" section
        if (indexPath.row == 0) {
            // template: personal (rounded image)
            
            [backgroundImageView setImage:[UIImage imageNamed:@"template-bg-personal"]];
            
            categoryLabel.text = @"Personal";
            UIImage *resizedSquareImage = [[[UIImage imageNamed:@"Paul-G-Glass.JPG"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
            [profileImageView setImage:resizedSquareImage];
            // Make the profile image rounded
            profileImageView.layer.cornerRadius = 33.0f;
            profileImageView.layer.masksToBounds = YES;
        } else if (indexPath.row == 1) {
            // template: business (rounded corner rectangle)
            
            [backgroundImageView setImage:[UIImage imageNamed:@"template-bg-business"]];
            
            categoryLabel.text = @"Business";
            UIImage *resizedSquareImage = [[[UIImage imageNamed:@"wellnessclub.jpg"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
            [profileImageView setImage:resizedSquareImage];
            profileImageView.layer.cornerRadius = 4.0f;
            profileImageView.layer.masksToBounds = YES;
        }
    }
    [self.view bringSubviewToFront:profileImageView];

    

    
    // cardDataString need to store label information
    self.cardDataString = [NSString stringWithFormat:@"%@",  @"Anvil"];
    
    // The index for the selected card.
    int selectedCard = 1;
//    // Create the PFFile object with the data of the image
//    // Convert backgroundImg
//    NSData *backgroundImgViewData = UIImagePNGRepresentation(backgroundImageView.image);
//    PFFile *backgroundImgViewFile = [PFFile fileWithName:@"backgroundImg" data:backgroundImgViewData];
//    
//    // Convert profileImg
//    NSData *profileImgViewData = UIImagePNGRepresentation(profileImageView.image);
//    PFFile *profileImgViewFile = [PFFile fileWithName:@"profileImg" data:profileImgViewData];
    
    if (indexPath.section == 0) {
        // "templates" section
        if (indexPath.row == selectedCard) {
            /////////////
            /// Parse
            /////////////
            // The image has now been uploaded to Parse. Associate it with a new object
            PFObject* newCard = [PFObject objectWithClassName:@"Card"];
            
            [newCard setObject:self.cardDataString forKey:@"cardDataString"];
            
            [newCard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded){
                    NSLog(@"Object Uploaded!");
                    self.cardID = [NSString stringWithFormat:@"%@", [newCard objectId]];
                    NSLog(@"Object id %@",self.cardID);
                }
                else{
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    NSLog(@"Error: %@", errorString);
                }
                
            }];
            
            // Create the PFFile object with the data of the image
            // Convert backgroundImg
            NSData *backgroundImgViewData = UIImagePNGRepresentation(backgroundImageView.image);
            PFFile *backgroundImgViewFile = [PFFile fileWithName:@"backgroundImg" data:backgroundImgViewData];
            
            // Convert profileImg
            NSData *profileImgViewData = UIImagePNGRepresentation(profileImageView.image);
            PFFile *profileImgViewFile = [PFFile fileWithName:@"profileImg" data:profileImgViewData];
            
            // Save the images (backgroundImgView, profileImgView) to Parse
            // Save backgroundImgViewFile
            [backgroundImgViewFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    [newCard setObject:backgroundImgViewFile forKey:@"backgroundImgView"];
                    
                    [newCard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            NSLog(@" backgroundImg Saved");
                        }
                        else{
                            // Error
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                }
            }];
            // Save profileImgViewFile
            [profileImgViewFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    [newCard setObject:profileImgViewFile forKey:@"profileImgView"];
                    
                    [newCard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            NSLog(@"profileImg Saved");
                        }
                        else{
                            // Error
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
                }
            }];

            
            
            // Make sure to check this.
            NSLog(@"We want to fetch data using this cardID %@",self.cardID);
            
            self.cardID = [NSString stringWithFormat:@"%@", @"UovN26xqat"];
            
            PFQuery *query = [PFQuery queryWithClassName:@"Card"];
            [query getObjectInBackgroundWithId:self.cardID block:^(PFObject *recievedCard, NSError *error) {
                // Do something with the returned PFObject in the gameScore variable.
                // NSLog(@"%@", recievedCard);
                NSString *objectId = recievedCard.objectId;
                NSLog(@"Finally we query this objectId: %@", objectId);
                
                
                PFFile *backgroundImgViewLoad = [recievedCard objectForKey:@"backgroundImgView"];
                [backgroundImgViewLoad getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                    }
                }];
                
                PFFile *profileImgViewLoad = [recievedCard objectForKey:@"profileImgView"];
                [profileImgViewLoad getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                    }
                }];
                
                
                
            }];
            
            
   
            
        }
    }
    
    

    

    
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

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
    self.dataToSend = [@"Test Data" dataUsingEncoding:NSUTF8StringEncoding];
    
    
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
