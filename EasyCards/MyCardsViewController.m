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
#import "TransferService.h"
#import <Parse/Parse.h>

@interface MyCardsViewController ()
{
    NSString *categoryToPass;
    BOOL startLoading;
}

@end

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
    self.allObjectIds = nil;
    
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
    self.allObjectIds = [[NSMutableArray alloc] init];
    
    
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
                [self.allObjectIds addObject:card.objectId];
                
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
            return [self.allBackgroundImages count];
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
    UILabel *objectIdLabelC = (UILabel *)[cell viewWithTag:2008];
    
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
    
    // Pass objectIdToBroadcast
    detailController.objectIdToBroadcast = objectIdLabelC.text;
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
    UILabel *objectIdLabel = (UILabel *)[cell viewWithTag:2008];
    
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
                
                objectIdLabel.text = self.allObjectIds[indexPath.row];
                
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


@end
