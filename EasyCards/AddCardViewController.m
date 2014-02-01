//
//  AddCardViewController.m
//  EasyCards
//
//  Created by Paul Wong on 2/1/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import "AddCardViewController.h"
#import "UIImage+Resize.h"
#import <Parse/Parse.h>

@interface AddCardViewController ()

@end

@implementation AddCardViewController
{
    UIImagePickerController *imagePicker;
    NSArray *textFields;
    NSString *replacementType;
    NSString *replacementInfo;
}

- (IBAction)cancel:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    // Save the newly created card info to both local and Parse
    
    // Start from !
    // Totally 9 strings
    self.cardDataString = [NSMutableString stringWithFormat:@"%@",  self.nameTextField.text];
    [self.cardDataString appendString: @"#&"];
    [self.cardDataString appendString: self.descriptionTextField.text];
    [self.cardDataString appendString: @"#&"];
    [self.cardDataString appendString: self.phoneTextField.text];
    [self.cardDataString appendString: @"#&"];
    [self.cardDataString appendString: self.twitterTextField.text];
    [self.cardDataString appendString: @"#&"];
    [self.cardDataString appendString: self.emailTextField.text];
    [self.cardDataString appendString: @"#&"];
    [self.cardDataString appendString: self.addressLineOneTextField.text];
    [self.cardDataString appendString: @"#&"];
    [self.cardDataString appendString: self.addressLineTwoTextField.text];
    
    NSLog(@"Card Information Data: %@",self.cardDataString);

    
    /////////////
    /// Parse
    /////////////
    // The image has now been uploaded to Parse. Associate it with a new object
    PFObject* newCard = [PFObject objectWithClassName:@"Card"];
    
    [newCard setObject:self.cardDataString forKey:@"cardDataString"];
    
    [newCard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded){
            NSLog(@"Object Uploaded!");
            self.cardID = [NSMutableString stringWithFormat:@"%@", [newCard objectId]];
            NSLog(@"Object id %@",self.cardID);
            // cardID is generated here
            // Retrieve Data, putting to previousSumCardID
            NSString *previousSumCardID =[[NSUserDefaults standardUserDefaults] stringForKey:@"Key"];
            self.currentSumCardID = [NSMutableString stringWithFormat:@"%@",  previousSumCardID];
            // Insert #* into two cardIDs
            [self.currentSumCardID appendString: @" "];
            [self.currentSumCardID appendString: self.cardID];
            
            // Save currentSumCardID into Key, NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:self.currentSumCardID forKey:@"Key"];
            NSLog(@"%@",self.currentSumCardID);
            self.cardID = nil;
            
        }
        else{
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", errorString);
        }
        
    }];
    
    // Create the PFFile object with the data of the image
    // Convert backgroundImg
    NSData *backgroundImgViewData = UIImagePNGRepresentation(self.backgroundImageView.image);
    PFFile *backgroundImgViewFile = [PFFile fileWithName:@"backgroundImg" data:backgroundImgViewData];
    
    // Convert profileImg
    NSData *profileImgViewData = UIImagePNGRepresentation(self.profileImageView.image);
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
    NSLog(@"We want to fetch data using this cardID %@", self.cardID);
    
    // Here I just take a case as the example
    self.cardID = [NSMutableString stringWithFormat:@"%@", @"kPzcNx68hH"];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Card"];
    [query getObjectInBackgroundWithId:self.cardID block:^(PFObject *recievedCard, NSError *error) {
        // Do something with the returned PFObject in the recievedCard variable.
        NSString *recievedData = recievedCard[@"cardDataString"];
        //NSLog(@"%@", recievedData);
        NSArray *recievedDataArray = [recievedData componentsSeparatedByString:@"#&"];
        //NSLog(@"%@", recievedDataArray);
        self.nameRecieved = [recievedDataArray objectAtIndex:0];
        self.descriptionRecieved = [recievedDataArray objectAtIndex:1];
        self.phoneRecieved = [recievedDataArray objectAtIndex:2];
        self.twitterRecieved = [recievedDataArray objectAtIndex:3];
        self.emailRecieved = [recievedDataArray objectAtIndex:4];
        self.addressLineOneRecieved = [recievedDataArray objectAtIndex:5];
        self.addressLineTwoRecieved = [recievedDataArray objectAtIndex:6];
        
        // NSLog(@"%@", self.addressLineOneRecieved);
        
<<<<<<< HEAD
        NSLog(@"%@", recievedData);
        // NSString *objectId = [recievedCard cardDataString];
        // NSLog(@"Finally we query this objectId: %@", objectId);
    
        // Decode the cardDataString
        // Separate a string into its individual characters
//        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[recievedCard.cardDataString length]];
//        for (int i=0; i < [myString length]; i++) {
//            NSString *ichar  = [NSString stringWithFormat:@"%c", [myString characterAtIndex:i]];
//            [characters addObject:ichar];
//        }
    
    
=======
>>>>>>> f2017ef3e15d27aa0dcef0ce4b22bba3de3e0cd6
    }];
    
    
    
}

- (IBAction)replaceProfileImage:(id)sender {
    replacementInfo = @"Replace Card Photo";
    [self initImagePicker];
    replacementType = @"ProfileImage";
}

- (IBAction)replaceBackgroundImage:(id)sender {
    replacementInfo = @"Replace Background";
    [self initImagePicker];
    replacementType = @"BackgroundImage";
}


- (void)initImagePicker
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:replacementInfo
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        [actionSheet showInView:self.view];
        
    } else {
        [self choosePhotoFromLibrary];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    for (UITextField *textField in textFields) {
        // Set each text field's delegate to be this view controller!
        // TextFieldDidBeginEditting is a delegate method of UITextFieldDelegate
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
    }
    
    if (buttonIndex == 0) {
        // Take photo
        [self takePhoto];
    } else if (buttonIndex == 1) {
        // Choose from library
        [self choosePhotoFromLibrary];
    } else if (buttonIndex == 2) {
        // Cancel
        // Do nothing...
    }
}

- (void)takePhoto
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    
    // following codes - unnecessary~
    //set the imagePicker to be like its native...  :)
    //get rid of the unnecessary strange incompatibility issue happening to buttons...
    //[[UIButton appearanceWhenContainedIn:[UIImagePickerController class], nil] setBackgroundImage:nil forState:UIControlStateNormal];
    //[[UINavigationBar appearanceWhenContainedIn:[UIImagePickerController class], nil] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.backgroundImageView.layer.cornerRadius = 4.0f;
    self.backgroundImageView.layer.masksToBounds = YES;
    
    if ([self.cardCategory isEqualToString:@"Personal"]) {
        // template: personal (rounded image)

        [self.backgroundImageView setImage:[UIImage imageNamed:@"template-bg-personal"]];
        
        UIImage *resizedSquareImage = [[[UIImage imageNamed:@"Paul-G-Glass.JPG"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
        [self.profileImageView setImage:resizedSquareImage];
        // Make the profile image rounded
        self.profileImageView.layer.cornerRadius = 33.0f;
        self.profileImageView.layer.masksToBounds = YES;
        
        self.nameTextField.placeholder = @"Personal Name";
        
        self.categoryLabel.text = @"Personal";
        
    } else if ([self.cardCategory isEqualToString:@"Business"]) {
        // template: business (rounded corner rectangle)
        
        [self.backgroundImageView setImage:[UIImage imageNamed:@"template-bg-business"]];
        
        UIImage *resizedSquareImage = [[[UIImage imageNamed:@"wellnessclub.jpg"] squareCroppedImage] resizedImageToWidth:132 andHeight:132];
        [self.profileImageView setImage:resizedSquareImage];
        self.profileImageView.layer.cornerRadius = 4.0f;
        self.profileImageView.layer.masksToBounds = YES;
        
        self.nameTextField.placeholder = @"Business Name";
        
        self.categoryLabel.text = @"Business";
    }
    
    [self.nameTextField becomeFirstResponder];
    
    textFields = @[ self.nameTextField, self.descriptionTextField, self.phoneTextField, self.twitterTextField, self.emailTextField, self.addressLineOneTextField, self.addressLineTwoTextField];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    [self.keyboardControls setDelegate:self];
    
    for (UITextField *textField in textFields) {
        // Set each text field's delegate to be this view controller!
        // TextFieldDidBeginEditting is a delegate method of UITextFieldDelegate
        [textField setDelegate:self];
    }
    
    // Make the profile image view alpha to be 0.5, so that user knows it is tappable... of course!
    self.profileImageView.alpha = 0.5;
    self.profileImageButton.hidden = NO;
    
    self.backgroundImageButton.hidden = NO;
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
}

#pragma mark Keyboard Controls Delegate

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    // Do nothing...
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if ([replacementType isEqualToString:@"ProfileImage"]) {
        [self.profileImageView setImage:[[image squareCroppedImage] resizedImageToWidth:132 andHeight:132]];
        // Once a new image is set, then reset alpha back to be 1.0
        self.profileImageView.alpha = 1.0;
        self.profileImageButton.alpha = 0.01;
    } else if ([replacementType isEqualToString:@"BackgroundImage"]) {
        [self.backgroundImageView setImage:[[image rectangleCroppedImageWith17To10] resizedImageToWidth:550 andHeight:324]];
        self.backgroundImageButton.alpha = 0.1;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
