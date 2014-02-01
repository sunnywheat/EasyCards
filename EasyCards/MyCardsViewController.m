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
    BOOL startLoading;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.allProfileImages = nil;
    self.allBackgroundImages = nil;
    self.allNames = nil;
    self.allDescriptions = nil;
    self.allPhones = nil;
    self.allTwitters = nil;
    self.allEmails = nil;
    self.allAddressLineOnes = nil;
    self.allAddressLineTwos = nil;
    self.allCreateDates = nil;
    
    self.allProfileImages = [[NSMutableArray alloc] init];
    self.allBackgroundImages = [[NSMutableArray alloc] init];
    self.allNames = [[NSMutableArray alloc] init];
    self.allDescriptions = [[NSMutableArray alloc] init];
    self.allPhones = [[NSMutableArray alloc] init];
    self.allTwitters = [[NSMutableArray alloc] init];
    self.allEmails = [[NSMutableArray alloc] init];
    self.allAddressLineOnes = [[NSMutableArray alloc] init];
    self.allAddressLineTwos = [[NSMutableArray alloc] init];
    self.allCreateDates = [[NSMutableArray alloc] init];
    
    self.allCardIDs = [[NSUserDefaults standardUserDefaults] objectForKey:@"AllCardIDs"];
    
    if ([self hasDesignedCards]) {
        for (NSString *queryObjectId in self.allCardIDs) {
            
            NSLog(@"query object id: %@", queryObjectId);
            
            PFQuery *query = [PFQuery queryWithClassName:@"Card"];
            [query getObjectInBackgroundWithId:queryObjectId block:^(PFObject *card, NSError *error) {
                
                NSString *cardDataStr = [card objectForKey:@"cardDataStr"];
                NSArray *cardDataArr = [cardDataStr componentsSeparatedByString:@"#&"];
                
                [self.allNames addObject:cardDataArr[0]];
                [self.allDescriptions addObject:cardDataArr[1]];
                [self.allPhones addObject:cardDataArr[2]];
                [self.allTwitters addObject:cardDataArr[3]];
                [self.allEmails addObject:cardDataArr[4]];
                [self.allAddressLineOnes addObject:cardDataArr[5]];
                [self.allAddressLineTwos addObject:cardDataArr[6]];
                
                NSDate *createDate = card.createdAt;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                NSString *createDateStr = [dateFormatter stringFromDate:createDate];
                [self.allCreateDates addObject:[NSString stringWithFormat:@"Created: %@", createDateStr]];
                
                PFFile *profileImgViewFile = [card objectForKey:@"profileImg"];
                [profileImgViewFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *profileImage = [UIImage imageWithData:data];
                        [self.allProfileImages addObject:profileImage];
                    }
                }];
                
                PFFile *backgroundImgFile = [card objectForKey:@"backgroundImg"];
                [backgroundImgFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *backgroundImage = [UIImage imageWithData:data];
                        [self.allBackgroundImages addObject:backgroundImage];
                        
                        if ([queryObjectId isEqualToString:[self.allCardIDs lastObject]]) {
                            NSLog(@"Loading last card now...");
                            startLoading = YES;
                            [self.tableView reloadData];
                        }
                        
                    }
                }];
                
            }];
        }
    }
}

#pragma mark - helper method
- (BOOL)hasDesignedCards
{
    return (self.allCardIDs != nil) && ([self.allCardIDs count] > 0);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self hasDesignedCards] && startLoading) {
        if (section == 0) {
            return @"Designed Cards";
        } else if (section == 1) {
            return @"Templates";
        }
    }
    return @"Templates";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self hasDesignedCards] && startLoading) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasDesignedCards] && startLoading) {
        if (section == 0) {
            return [self.allCardIDs count];
        } else if (section == 1) {
            return 2;
        }
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardDetailViewController *detailController = [[CardDetailViewController alloc] initWithNibName:@"CardDetailViewController" bundle:nil];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *backgroundImageView = (UIImageView *)[detailController.view viewWithTag:1000];
    UIImageView *profileImageView = (UIImageView *)[detailController.view viewWithTag:1001];
    
    UILabel *nameLabel = (UILabel *)[detailController.view viewWithTag:2001];
    UILabel *descriptionLabel = (UILabel *)[detailController.view viewWithTag:2002];
    UILabel *phoneLabel = (UILabel *)[detailController.view viewWithTag:2003];
    UILabel *twitterLabel = (UILabel *)[detailController.view viewWithTag:2004];
    UILabel *emailLabel = (UILabel *)[detailController.view viewWithTag:2005];
    UILabel *addressLineOneLabel = (UILabel *)[detailController.view viewWithTag:2006];
    UILabel *addressLineTwoLabel = (UILabel *)[detailController.view viewWithTag:2007];
    
    UIImageView *backgroundImageViewC = (UIImageView *)[cell viewWithTag:1000];
    UIImageView *profileImageViewC = (UIImageView *)[cell viewWithTag:1001];
    
    UILabel *nameLabelC = (UILabel *)[cell viewWithTag:2001];
    UILabel *descriptionLabelC = (UILabel *)[cell viewWithTag:2002];
    UILabel *phoneLabelC = (UILabel *)[cell viewWithTag:2003];
    UILabel *twitterLabelC = (UILabel *)[cell viewWithTag:2004];
    UILabel *emailLabelC = (UILabel *)[cell viewWithTag:2005];
    UILabel *addressLineOneLabelC = (UILabel *)[cell viewWithTag:2006];
    UILabel *addressLineTwoLabelC = (UILabel *)[cell viewWithTag:2007];
    
    nameLabel.text = nameLabelC.text;
    descriptionLabel.text = descriptionLabelC.text;
    phoneLabel.text = phoneLabelC.text;
    twitterLabel.text = twitterLabelC.text;
    emailLabel.text = emailLabelC.text;
    addressLineOneLabel.text = addressLineOneLabelC.text;
    addressLineTwoLabel.text = addressLineTwoLabelC.text;
    backgroundImageView.image = backgroundImageViewC.image;
    profileImageView.image = profileImageViewC.image;
    
    //self.navigationController.navigationBarHidden = YES;
    //self.tabBarController.tabBar.hidden = YES;
    //[self setNeedsStatusBarAppearanceUpdate];
    
    [detailController presentInParentViewController:self];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *backgroundImageView = (UIImageView *)[cell viewWithTag:1000];
    backgroundImageView.layer.cornerRadius = 4.0f;
    backgroundImageView.layer.masksToBounds = YES;
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:1001];
    
    UILabel *categoryLabel = (UILabel *)[cell viewWithTag:2000];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:2002];
    UILabel *phoneLabel = (UILabel *)[cell viewWithTag:2003];
    UILabel *twitterLabel = (UILabel *)[cell viewWithTag:2004];
    UILabel *emailLabel = (UILabel *)[cell viewWithTag:2005];
    UILabel *addressLineOneLabel = (UILabel *)[cell viewWithTag:2006];
    UILabel *addressLineTwoLabel = (UILabel *)[cell viewWithTag:2007];
    
    if ([self hasDesignedCards]) {
        if (startLoading) {
            if (indexPath.section == 0) {
                // Designed Cards
                
                
                NSLog(@"%d", [self.allBackgroundImages count]);
                
                [backgroundImageView setImage:self.allBackgroundImages[indexPath.row]];
                [profileImageView setImage:self.allProfileImages[indexPath.row]];
                nameLabel.text = self.allNames[indexPath.row];
                descriptionLabel.text = self.allDescriptions[indexPath.row];
                phoneLabel.text = self.allPhones[indexPath.row];
                twitterLabel.text = self.allTwitters[indexPath.row];
                emailLabel.text = self.allEmails[indexPath.row];
                addressLineOneLabel.text = self.allAddressLineOnes[indexPath.row];
                addressLineTwoLabel.text = self.allAddressLineTwos[indexPath.row];
                categoryLabel.text = self.allCreateDates[indexPath.row];
                
                
            } else if (indexPath.section == 1) {
                // Templates
                if (indexPath.row == 0) {
                    // template: personal (rounded image)
                    
                    [backgroundImageView setImage:[UIImage imageNamed:@"template-bg-personal"]];
                    
                    UIImage *resizedSquareImage = [[[UIImage imageNamed:@"Paul-G-Glass.JPG"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
                    [profileImageView setImage:resizedSquareImage];
                    // Make the profile image rounded
                    profileImageView.layer.cornerRadius = 33.0f;
                    profileImageView.layer.masksToBounds = YES;
                    
                    categoryLabel.text = @"Personal";
                    
                    nameLabel.text = @"Paul Wong";
                    descriptionLabel.text = @"Avid iOS Developer";
                    phoneLabel.text = @"412-482-7996";
                    twitterLabel.text = @"@paulwong90";
                    emailLabel.text = @"paulloveshk@gmail.com";
                    addressLineOneLabel.text = @"5874 Shady Forbes Terrace";
                    addressLineTwoLabel.text = @"Pittsburgh, PA 15217";
                    
                } else if (indexPath.row == 1) {
                    // template: business (rounded corner rectangle)
                    
                    [backgroundImageView setImage:[UIImage imageNamed:@"template-bg-business"]];
                    
                    UIImage *resizedSquareImage = [[[UIImage imageNamed:@"wellnessclub.jpg"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
                    [profileImageView setImage:resizedSquareImage];
                    profileImageView.layer.cornerRadius = 4.0f;
                    profileImageView.layer.masksToBounds = YES;
                    
                    categoryLabel.text = @"Business";
                    
                    nameLabel.text = @"Wellness Club";
                    descriptionLabel.text = @"Bodywork Shop";
                    phoneLabel.text = @"857-204-5878";
                    twitterLabel.text = @"@wellnessclub";
                    emailLabel.text = @"qingmango@gmail.com";
                    addressLineOneLabel.text = @"278 Centre St";
                    addressLineTwoLabel.text = @"Quincy, MA 02169";
                    
                }
            }
        }
    } else {
        // Only templates are involved!
        if (indexPath.row == 0) {
            // template: personal (rounded image)
            
            [backgroundImageView setImage:[UIImage imageNamed:@"template-bg-personal"]];
            
            UIImage *resizedSquareImage = [[[UIImage imageNamed:@"Paul-G-Glass.JPG"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
            [profileImageView setImage:resizedSquareImage];
            // Make the profile image rounded
            profileImageView.layer.cornerRadius = 33.0f;
            profileImageView.layer.masksToBounds = YES;
            
            categoryLabel.text = @"Personal";
            
            nameLabel.text = @"Paul Wong";
            descriptionLabel.text = @"Avid iOS Developer";
            phoneLabel.text = @"412-482-7996";
            twitterLabel.text = @"@paulwong90";
            emailLabel.text = @"paulloveshk@gmail.com";
            addressLineOneLabel.text = @"5874 Shady Forbes Terrace";
            addressLineTwoLabel.text = @"Pittsburgh, PA 15217";
            
        } else if (indexPath.row == 1) {
            // template: business (rounded corner rectangle)
            
            [backgroundImageView setImage:[UIImage imageNamed:@"template-bg-business"]];
            
            UIImage *resizedSquareImage = [[[UIImage imageNamed:@"wellnessclub.jpg"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
            [profileImageView setImage:resizedSquareImage];
            profileImageView.layer.cornerRadius = 4.0f;
            profileImageView.layer.masksToBounds = YES;
            
            categoryLabel.text = @"Business";
            
            nameLabel.text = @"Wellness Club";
            descriptionLabel.text = @"Bodywork Shop";
            phoneLabel.text = @"857-204-5878";
            twitterLabel.text = @"@wellnessclub";
            emailLabel.text = @"qingmango@gmail.com";
            addressLineOneLabel.text = @"278 Centre St";
            addressLineTwoLabel.text = @"Quincy, MA 02169";
            
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
