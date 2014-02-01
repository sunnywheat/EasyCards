//
//  MyCardsViewController.h
//  EasyCards
//
//  Created by Paul Wong on 1/31/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardDetailViewController.h"

@interface MyCardsViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic,assign) NSString *cardID;

// cardDataString would be used for several time to store Name, Phone, Email and so on
@property (nonatomic,assign) NSString *cardDataStr;

@property (nonatomic, strong) NSMutableArray *allCardIDs;

@property (nonatomic, strong) NSMutableArray *allProfileImages;
@property (nonatomic, strong) NSMutableArray *allBackgroundImages;
@property (nonatomic, strong) NSMutableArray *allNames;
@property (nonatomic, strong) NSMutableArray *allDescriptions;
@property (nonatomic, strong) NSMutableArray *allPhones;
@property (nonatomic, strong) NSMutableArray *allTwitters;
@property (nonatomic, strong) NSMutableArray *allEmails;
@property (nonatomic, strong) NSMutableArray *allAddressLineOnes;
@property (nonatomic, strong) NSMutableArray *allAddressLineTwos;
@property (nonatomic, strong) NSMutableArray *allCreateDates;

@end
