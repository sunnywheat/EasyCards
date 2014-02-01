//
//  CollectionViewController.m
//  EasyCards
//
//  Created by Paul Wong on 1/31/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import "CollectionViewController.h"
#import <Parse/Parse.h>

@interface CollectionViewController ()

@end

@implementation CollectionViewController

- (void)viewWillAppear:(BOOL)animated
{
    
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
    //self.allObjectIds = nil;
    
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
    //self.allObjectIds = [[NSMutableArray alloc] init];
    
    self.allReceivedCardIDs = [[NSUserDefaults standardUserDefaults] objectForKey:@"AllReceivedCardIDs"];
    NSLog(@"%@", self.allReceivedCardIDs);
    
    for (NSString *queryObjectId in self.allReceivedCardIDs) {
        
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
            //[self.allObjectIds addObject:card.objectId];
            
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
                    
                    if ([queryObjectId isEqualToString:[self.allReceivedCardIDs lastObject]]) {
                        NSLog(@"Loading last card now...");
                        [self.tableView reloadData];
                    }
                    
                }
            }];
        
            
        }];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // return [self.allReceivedCardIDs count];
    return [self.allBackgroundImages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

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
    
    //objectIdLabel.text = self.allObjectIds[indexPath.row];
    
    categoryLabel.text = self.allCreateDates[indexPath.row];
    categoryLabel.text = @"From Paul Wong";
    
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
