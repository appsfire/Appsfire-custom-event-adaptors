//
//  AFAppDelegate.m
//  MoPub Mediation Demo
//
//  Created by Ali Karagoz on 17/10/2013.
//  Copyright (c) 2013 Appsfire. All rights reserved.
//

#import "AFAppDelegate.h"
#import "AFViewController.h"
#import "AppsfireSDK.h"
#import "AppsfireAdSDK.h"

@implementation AFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*
     * Appsfire SDK.
     */
    
    #error Add your Appsfire SDK Token and Secret Key below.
    NSError *error = [AppsfireSDK connectWithSDKToken:@"" secretKey:@"" features:AFSDKFeatureMonetization parameters:nil];
    if (error) {
        NSLog(@"Error while initializing the Appsfire SDK: %@", error.description);
    }
    
    #if DEBUG
    #warning Replace by `NO` if you don't want to see test Ads in DEBUG mode.
        [AppsfireAdSDK setDebugModeEnabled:YES];
    #endif
    
    /*
     * UI Implementation.
     */
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    AFViewController *viewController = [[AFViewController alloc] init];
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    return YES;
    
}

@end
