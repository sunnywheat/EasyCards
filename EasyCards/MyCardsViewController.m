//
//  MyCardsViewController.m
//  EasyCards
//
//  Created by Paul Wong on 1/31/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import "MyCardsViewController.h"
#import "UIImage+Resize.h"

@interface MyCardsViewController ()

@end

@implementation MyCardsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.separatorColor = [UIColor clearColor];
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
    
    UIImageView *backgroundImgView = (UIImageView *)[cell viewWithTag:1000];
    backgroundImgView.layer.cornerRadius = 4.0f;
    backgroundImgView.layer.masksToBounds = YES;
    
    UIImageView *profileImgView = (UIImageView *)[cell viewWithTag:1001];
    
    if (indexPath.section == 0) {
        // "templates" section
        if (indexPath.row == 0) {
            // template: personal (rounded image)
            
            [backgroundImgView setImage:[UIImage imageNamed:@"template-bg-personal"]];
            
            categoryLabel.text = @"Personal";
            UIImage *resizedSquareImage = [[[UIImage imageNamed:@"Paul-G-Glass.JPG"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
            [profileImgView setImage:resizedSquareImage];
            // Make the profile image rounded
            profileImgView.layer.cornerRadius = 33.0f;
            profileImgView.layer.masksToBounds = YES;
        } else if (indexPath.row == 1) {
            // template: business (rounded corner rectangle)
            
            [backgroundImgView setImage:[UIImage imageNamed:@"template-bg-business"]];
            
            categoryLabel.text = @"Business";
            UIImage *resizedSquareImage = [[[UIImage imageNamed:@"wellnessclub.jpg"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
            [profileImgView setImage:resizedSquareImage];
            profileImgView.layer.cornerRadius = 4.0f;
            profileImgView.layer.masksToBounds = YES;
        }
    }
    [self.view bringSubviewToFront:profileImgView];
    
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
