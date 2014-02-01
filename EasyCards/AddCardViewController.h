//
//  AddCardViewController.h
//  EasyCards
//
//  Created by Paul Wong on 2/1/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"

@interface AddCardViewController : UIViewController <BSKeyboardControlsDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) IBOutlet UIButton *profileImageButton;
@property (strong, nonatomic) IBOutlet UIButton *backgroundImageButton;

@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *twitterTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *addressLineOneTextField;
@property (strong, nonatomic) IBOutlet UITextField *addressLineTwoTextField;

// Receive data
@property (nonatomic, strong) NSString *nameRecieved;
@property (nonatomic, strong) NSString *descriptionRecieved;
@property (nonatomic, strong) NSString *phoneRecieved;
@property (nonatomic, strong) NSString *twitterRecieved;
@property (nonatomic, strong) NSString *emailRecieved;
@property (nonatomic, strong) NSString *addressLineOneRecieved;
@property (nonatomic, strong) NSString *addressLineTwoRecieved;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;


@property (nonatomic, strong) NSString *cardCategory;

// Please no NSString anymore during hackathon
// cardID is for bluetooth trasmittion
@property (nonatomic,assign) NSMutableString *cardID;
// Save cardID string value to NSUserDefaults
@property (nonatomic,assign) NSMutableString *currentSumCardID;

// cardDataString would be used for several time to store Name, Phone, Email and so on
// String is sent to Parse
@property (nonatomic,assign) NSMutableString *cardDataString;


@end
