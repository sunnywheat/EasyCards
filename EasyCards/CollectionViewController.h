//
//  CollectionViewController.h
//  EasyCards
//
//  Created by Paul Wong on 1/31/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *allReceivedCardIDs;

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

// @property (nonatomic, strong) NSMutableArray *allObjectIds;

@end
