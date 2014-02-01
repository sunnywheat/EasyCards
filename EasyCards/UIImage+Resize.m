//
//  UIImage+Resize.m
//  OAuthStarterKit
//
//  Created by Paul Wong on 1/24/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizedImageToWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRect = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:newRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage *)squareCroppedImage
{
    // cropped around center! exactly what i want!
    UIImage *image = self;
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width != height) {
        CGFloat newDimension = MIN(width, height);
        CGFloat widthOffset = (width - newDimension) / 2;
        CGFloat heightOffset = (height - newDimension) / 2;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimension, newDimension), NO, 0.);
        [image drawAtPoint:CGPointMake(-widthOffset, -heightOffset)
                 blendMode:kCGBlendModeCopy
                     alpha:1.];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

- (UIImage *)rectangleCroppedImageWith17To10
{
    // cropped around center! exactly what i want!
    UIImage *image = self;
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;

    CGFloat newWidth = 0;
    CGFloat newHeight = 0;
    CGFloat widthOffset = 0;
    CGFloat heightOffset = 0;
    if (width > 1.7 * height) {
        widthOffset = (width - 1.7 * height) / 2;
        heightOffset = 0;
        newWidth = 1.7 * height;
        newHeight = height;
    } else if (width < 1.7 * height) {
        widthOffset = 0;
        heightOffset = (height - width / 1.7) / 2;
        newWidth = width;
        newHeight = width / 1.7;
    } else {
        newWidth = width;
        newHeight = height;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.);
    [image drawAtPoint:CGPointMake(-widthOffset, -heightOffset)
             blendMode:kCGBlendModeCopy
                 alpha:1.];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}




@end
