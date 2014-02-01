//
//  AppDelegate.m
//  EasyCards
//
//  Created by Paul Wong on 1/31/14.
//  Copyright (c) 2014 Paul Wong. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
        
    
    // Register our parse app with the service
    [Parse setApplicationId:@"EPSrSd6JZkbihviEVLaMLv6xYh5qzyb9c1VCF3S9"
                  clientKey:@"C1YWMbU6HQxQmkeLlsL25nQpoqzXrxXM9VUKfKrh"];  
    
    // Create Some Sample Objects for the Parse test.
    
    //    PFObject *anotherPlayer = [PFObject objectWithClassName:@"Player"];
    //    [anotherPlayer setObject:@"Jack" forKey:@"Name"];
    //    [anotherPlayer setObject:[NSNumber numberWithInt:840] forKey:@"Score"];
    //    [anotherPlayer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //        
    //        if (succeeded){
    //            NSLog(@"Object Uploaded!");
    //        }
    //        else{
    //            NSString *errorString = [[error userInfo] objectForKey:@"error"];
    //            NSLog(@"Error: %@", errorString);
    //        }
    //        
    //    }];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
