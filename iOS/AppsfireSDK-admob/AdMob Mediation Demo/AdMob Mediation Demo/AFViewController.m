//
//  AFViewController.m
//  AdMob Mediation Demo
//
//  Created by Ali Karagoz on 17/10/2013.
//  Copyright (c) 2013 Appsfire. All rights reserved.
//

#import "AFViewController.h"
#import "AppsfireAdSDK.h"
#import "AppsfireSDK.h"
#import "GADInterstitial.h"

@interface AFViewController () <GADInterstitialDelegate>

@property (nonatomic) UIButton *button;
@property (nonatomic) GADInterstitial *interstitial;

- (void)loadInterstitial;
- (void)showAd:(id)sender;

@end

@implementation AFViewController

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    
    // Configuring the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Button
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.button setTitle:@"Show Ad" forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(showAd:) forControlEvents:UIControlEventTouchUpInside];
    [self.button sizeToFit];
    
    self.button.center = self.view.center;
    self.button.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|
                                    UIViewAutoresizingFlexibleRightMargin|
                                    UIViewAutoresizingFlexibleTopMargin|
                                    UIViewAutoresizingFlexibleBottomMargin);
    [self.view addSubview:self.button];
    
    // We disable the button until we have an ad.
    self.button.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load AdMob Interstitial.
    [self loadInterstitial];
}

#pragma mark - AdMob

- (void)loadInterstitial {
    // Instantiate the interstitial using the class convenience method.
    self.interstitial = [[GADInterstitial alloc] init];
    
    #error Add your AdMob interstitial Ad Unit Id.
    self.interstitial.adUnitID = @"<ADMOB_ADUNIT_ID>";
    
    // Creating the request.
    GADRequest *request = [GADRequest request];
    
    // Loads an interstitial ad.
    [self.interstitial loadRequest:request];
    
    // Delegate
    self.interstitial.delegate = self;
}

- (void)showAd:(id)sender {
    [self.interstitial presentFromRootViewController:self];
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Enabling the button if the interstitial is ready.
    if (self.interstitial.isReady) {
        self.button.enabled = YES;
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Re-loading a new ad.
    self.button.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadInterstitial];
    });
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
