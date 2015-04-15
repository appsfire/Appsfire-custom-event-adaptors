//
//  AFViewController.m
//  MoPub Mediation Demo
//
//  Created by Vincent Germain on 13/04/2015.
//  Copyright (c) 2015 Appsfire. All rights reserved.
//

#import "AFViewController.h"
// appsfire
#import "AppsfireAdSDK.h"
#import "AppsfireSDK.h"
// mopub
#import "MPInterstitialAdController.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAd.h"
#import "MPNativeAdDelegate.h"
//
#import "AFCustomNativeAdView.h"

@interface AFViewController () <MPInterstitialAdControllerDelegate, MPNativeAdDelegate>

// interstitial show button
@property (nonatomic, strong) UIButton *interstitialShowButton;

// interstitial ad controller
@property (nonatomic, strong) MPInterstitialAdController *interstitialAdController;

// native ad refresh button
@property (nonatomic, strong) UIButton *nativeAdRefreshButton;

// native ad request
@property (nonatomic, strong) MPNativeAdRequest *nativeAdRequest;

// native ad (object)
@property (nonatomic, strong) MPNativeAd *nativeAd;

// native ad view
@property (nonatomic, strong) AFCustomNativeAdView *nativeAdView;

// interstitial
- (void)loadInterstitial;
- (void)showInterstitialAd;

// native ad
- (void)loadNativeAd;

@end

@implementation AFViewController

#pragma mark - UIViewController

- (void)loadView {
    
    //
    [super loadView];
    
    //
    self.view.backgroundColor = [UIColor whiteColor];
    
    // interstitial show button
    self.interstitialShowButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.interstitialShowButton.enabled = NO;
    self.interstitialShowButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 20.0, 6.0, 20.0);
    self.interstitialShowButton.backgroundColor = [UIColor darkGrayColor];
    [self.interstitialShowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.interstitialShowButton setTitle:@"Show Interstitial Ad" forState:UIControlStateNormal];
    [self.interstitialShowButton addTarget:self action:@selector(showInterstitialAd) forControlEvents:UIControlEventTouchUpInside];
    [self.interstitialShowButton sizeToFit];
    [self.view addSubview:self.interstitialShowButton];
    
    // native ad refresh button
    self.nativeAdRefreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nativeAdRefreshButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 20.0, 6.0, 20.0);
    self.nativeAdRefreshButton.backgroundColor = [UIColor darkGrayColor];
    [self.nativeAdRefreshButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.nativeAdRefreshButton setTitle:@"Refresh Native Ad" forState:UIControlStateNormal];
    [self.nativeAdRefreshButton addTarget:self action:@selector(loadNativeAd) forControlEvents:UIControlEventTouchUpInside];
    [self.nativeAdRefreshButton sizeToFit];
    [self.view addSubview:self.nativeAdRefreshButton];
    
    // native ad view
    self.nativeAdView = [[AFCustomNativeAdView alloc] init];
    self.nativeAdView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    [self.nativeAdView clearsContextBeforeDrawing];
    [self.view addSubview:self.nativeAdView];
    
    //
    [self loadInterstitial];
    [self loadNativeAd];

}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    
    CGRect interstitialButtonFrame;
    CGRect nativeAdButtonFrame;
    CGRect nativeAdViewFrame;
    CGFloat spacing, nativeAdHeight, totalHeight;
    
    // spacing
    spacing = 12.0;
    nativeAdHeight = 120.0;
    
    // total height
    totalHeight = CGRectGetHeight(self.nativeAdRefreshButton.frame) + spacing + CGRectGetHeight(self.nativeAdRefreshButton.frame) + spacing + nativeAdHeight;
    
    // interstitial button frame
    interstitialButtonFrame = self.interstitialShowButton.frame;
    interstitialButtonFrame.origin.x = floor(CGRectGetWidth(self.view.frame) / 2.0 - CGRectGetWidth(interstitialButtonFrame) / 2.0);
    interstitialButtonFrame.origin.y = CGRectGetHeight(self.view.frame) / 2.0 - totalHeight / 2.0;
    self.interstitialShowButton.frame = interstitialButtonFrame;
    
    // native ad button frame
    nativeAdButtonFrame = self.nativeAdRefreshButton.frame;
    nativeAdButtonFrame.origin.x = floor(CGRectGetWidth(self.view.frame) / 2.0 - CGRectGetWidth(nativeAdButtonFrame) / 2.0);
    nativeAdButtonFrame.origin.y = CGRectGetMaxY(interstitialButtonFrame) + spacing;
    self.nativeAdRefreshButton.frame = nativeAdButtonFrame;
    
    // native ad view frame
    nativeAdViewFrame = CGRectZero;
    nativeAdViewFrame.size.height = nativeAdHeight;
    nativeAdViewFrame.size.width = CGRectGetWidth(self.view.frame) - 20.0;
    nativeAdViewFrame.origin.x = floor(CGRectGetWidth(self.view.frame) / 2.0 - CGRectGetWidth(nativeAdViewFrame) / 2.0);
    nativeAdViewFrame.origin.y = CGRectGetMaxY(nativeAdButtonFrame) + spacing;
    self.nativeAdView.frame = nativeAdViewFrame;

}

#pragma mark - Load and Show Interstitial

- (void)loadInterstitial {
    
    //
    self.interstitialShowButton.enabled = NO;

    // instantiate the interstitial using the class convenience method
    #error Add your MoPub Ad Unit Id below. Please read the `README.md` file to learn how to get one!
    self.interstitialAdController = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@""];
    
    // delegate
    self.interstitialAdController.delegate = self;

    // fetch the interstitial ad
    [self.interstitialAdController loadAd];
    
}

- (void)showInterstitialAd {
    
    if (self.interstitialAdController.ready)
        [self.interstitialAdController showFromViewController:self];
    else
        [[[UIAlertView alloc] initWithTitle:@"Interstitial" message:@"No ready yet" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    
}

#pragma mark - Load and Show Native Ad

- (void)loadNativeAd {
    
    // stop if a native ad is already in process
    if (self.nativeAdRequest != nil)
        return;
    
    // create native ad
    #error Add your MoPub Ad Unit Id below. Please read the `README.md` file to learn how to get one!
    self.nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@""];
    
    // start request with block
    [self.nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
       
        //
        self.nativeAdRequest = nil;
        
        //
        if (error) {
           
            [[[UIAlertView alloc] initWithTitle:@"Native Ad" message:[NSString stringWithFormat:@"error = %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
            
        } else {
            
            self.nativeAd = response;
            self.nativeAd.delegate = self;
            [self.nativeAd prepareForDisplayInView:self.nativeAdView];
            
        }
        
    }];
    
}

#pragma mark - Mopub Interstitial Delegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // enable the button once the interstitial is ready
    if (self.interstitialAdController.ready) {
        self.interstitialShowButton.enabled = YES;
    }
    
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // reload a new ad
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadInterstitial];
    });
    
}

#pragma mark - Native Ad Delegate

- (UIViewController *)viewControllerForPresentingModalView {
    
    return self;
    
}

@end
