//
//  MyCardsViewController.h
//  EasyCards
//
//  Created by Paul Wong on 1/31/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCardsViewController : UITableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;

@property (nonatomic,assign) NSString *cardID;

// cardDataString would be used for several time to store Name, Phone, Email and so on
@property (nonatomic,assign) NSString *cardDataString;

@end
