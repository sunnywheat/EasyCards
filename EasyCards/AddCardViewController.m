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

- (void)closeScreen
{
    NSLog(@"screen is being closed...");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self closeScreen];
}

- (IBAction)save:(id)sender {
    
    [self saveNewCard];
    
    [self performSelector:@selector(closeScreen) withObject:self afterDelay:3];
}

- (void)saveNewCard
{
    // Save the newly created card info to both local and Parse
    
    self.cardDataStr = (NSMutableString *)[@[self.nameTextField.text, self.descriptionTextField.text, self.phoneTextField.text, self.twitterTextField.text, self.emailTextField.text, self.addressLineOneTextField.text, self.addressLineTwoTextField.text] componentsJoinedByString:@"#&"];
    
    /////////////
    /// Parse
    /////////////
    // The image has now been uploaded to Parse. Associate it with a new object.
    PFObject* newCard = [PFObject objectWithClassName:@"Card"];
    
    [newCard setObject:self.cardDataStr forKey:@"cardDataStr"];
    
    [newCard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded){
            self.cardID = [NSMutableString stringWithFormat:@"%@", [newCard objectId]];
            
            self.allCardIDs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AllCardIDs"] mutableCopy];
            if (self.allCardIDs == nil) {
                self.allCardIDs = [[NSMutableArray alloc] init];
            }
            [self.allCardIDs insertObject:self.cardID atIndex:0];
            [[NSUserDefaults standardUserDefaults] setObject:self.allCardIDs forKey:@"AllCardIDs"];
        }
        else{
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", errorString);
        }
        
    }];
    
    // Create the PFFile object with the data of the image
    // Convert backgroundImg
    NSData *backgroundImgData = UIImagePNGRepresentation(self.backgroundImageView.image);
    PFFile *backgroundImgFile = [PFFile fileWithName:@"backgroundImg" data:backgroundImgData];
    
    // Convert profileImg
    NSData *profileImgData = UIImagePNGRepresentation(self.profileImageView.image);
    PFFile *profileImgFile = [PFFile fileWithName:@"profileImg" data:profileImgData];
    
    // Save the images (backgroundImg, profileImg) to Parse
    
    // Save backgroundImgFile
    [backgroundImgFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [newCard setObject:backgroundImgFile forKey:@"backgroundImg"];
            
            [newCard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"backgroundImg Saved");
                }
                else{
                    // Error
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }];
    
    // Save profileImgFile
    [profileImgFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [newCard setObject:profileImgFile forKey:@"profileImg"];
            
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
}

- (IBAction)replaceProfileImage:(id)sender {
    replacementInfo = @"Replace Card Photo";
    [self initImagePicker];
    replacementType = @"ProfileImage";
}

- (IBAction)replaceBackgroundImage:(id)sender {
    replacementInfo = @"Replace Background Photo";
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
