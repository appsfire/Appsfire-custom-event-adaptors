/*!
 *  @header    AFAdMobCustomEventInterstitial.m
 *  @abstract  Appsfire AdMob Interstitial Custom Event class.
 *  @version   1.3
 */

/*
 Copyright 2010-2014 Appsfire SAS. All rights reserved.
 
 Redistribution and use in source and binary forms, without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY APPSFIRE SAS ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL APPSFIRE SAS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AFAdMobCustomEventInterstitial.h"

// Appsfire SDK
#import "AppsfireAdSDK.h"
#import "AppsfireAdTimerView.h"

static NSTimeInterval const AFAdMobCustomEventInterstitialAdCheckInterval = 1.0;
static NSTimeInterval const AFAdMobCustomEventInterstitialTimerInterval = 3.0;
static NSUInteger const AFAdMobCustomEventInterstitialAdCheckTimeout = 30;

@interface AFAdMobCustomEventInterstitial () <AppsfireAdSDKDelegate>

@property (nonatomic, assign) AFAdSDKModalType modalType;
@property (nonatomic, assign) NSTimer *adCheckTimer;
@property (nonatomic, assign) BOOL shouldShowTimer;
@property (nonatomic, assign, getter=isDelegateAlreadyNotified) BOOL delegateAlreadyNotified;
@property (nonatomic, assign) NSUInteger adCheckCount;

// Server Parameters
- (void)parseServerParameter:(NSString *)serverParameter;

// Shows Appsfire interstitials if those are available.
- (void)showAppsfireInterstitialsFromRootViewController:(UIViewController *)rootViewController;

// Checks the availability of Ads.
- (void)checkAdAvailability;

@end

@implementation AFAdMobCustomEventInterstitial

// Will be set by the AdMob SDK.
@synthesize delegate;

#pragma mark - Dealloc

- (void)dealloc {
    
    // Cancel any running timer.
    [_adCheckTimer invalidate], _adCheckTimer = nil;
    
    self.delegate = nil;
    [AppsfireAdSDK setDelegate:nil];
}

#pragma mark - GADCustomEventInterstitial

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
    
    // Variable init.
    _adCheckCount = 0;
    _delegateAlreadyNotified = NO;
    
    // Default values
    _modalType = AFAdSDKModalTypeSushi;
    _shouldShowTimer = NO;
    
    // Getting custom values.
    [self parseServerParameter:serverParameter];
    
    // Specify the delegate to handle various interactions with the Appsfire Ad SDK.
    [AppsfireAdSDK setDelegate:self];
    
    // Tells Ad SDK to prepare, this method is automatically called during a modal ad request.
    [AppsfireAdSDK prepare];
    
    // Check if ads are available.
    [self checkAdAvailability];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self showAppsfireInterstitialsFromRootViewController:rootViewController];
}

- (void)checkAdAvailability {
    
    // Cancel any running timer.
    [_adCheckTimer invalidate], _adCheckTimer = nil;
    
    // Timeout failsafe.
    if (_adCheckCount >= AFAdMobCustomEventInterstitialAdCheckTimeout) {
        
        // We consider having no ads from now.
        if ([self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
            NSError *error = [NSError errorWithDomain:@"com.appsfire.sdk" code:AFSDKErrorCodeAdvertisingNoAd userInfo:@{NSLocalizedDescriptionKey : @"No Ads to display."}];
            [self.delegate customEventInterstitial:self didFailAd:error];
        }
    }
    
    // We need to know if we have available ads.
    AFAdSDKAdAvailability availability = [AppsfireAdSDK isThereAModalAdAvailableForType:_modalType];
    
    // Depending on the availability.
    switch (availability) {
            
        // If we are in a pending situation we fire a timer to retry every second.
        case AFAdSDKAdAvailabilityPending: {
            _adCheckTimer = [NSTimer scheduledTimerWithTimeInterval:AFAdMobCustomEventInterstitialAdCheckInterval target:self selector:@selector(checkAdAvailability) userInfo:nil repeats:NO];
        } break;
            
        // If we have ads we inform the delegate.
        case AFAdSDKAdAvailabilityYes: {
            if ([self.delegate respondsToSelector:@selector(customEventInterstitial:didReceiveAd:)] && !self.isDelegateAlreadyNotified) {
                [self.delegate customEventInterstitial:self didReceiveAd:nil];
                
                // We prevent from notifying the delegate twice.
                _delegateAlreadyNotified = YES;
            }
        } break;
            
        // If we have no ads we inform the delegate.
        case AFAdSDKAdAvailabilityNo: {
            if ([self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
                NSError *error = [NSError errorWithDomain:@"com.appsfire.sdk" code:AFSDKErrorCodeAdvertisingNoAd userInfo:@{NSLocalizedDescriptionKey : @"No Ads to display."}];
                [self.delegate customEventInterstitial:self didFailAd:error];
            }
        } break;
            
        default: {
        } break;
    }
    
    _adCheckCount++;
}


#pragma mark - AppsfireAdSDKDelegate

- (void)modalAdIsReadyForRequest {
    if ([self.delegate respondsToSelector:@selector(customEventInterstitial:didReceiveAd:)] && !self.isDelegateAlreadyNotified) {
        [self.delegate customEventInterstitial:self didReceiveAd:nil];
        
        // We prevent from notifying the delegate twice.
        _delegateAlreadyNotified = YES;
    }
}

- (void)modalAdRequestDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)]) {
        [self.delegate customEventInterstitial:self didFailAd:error];
    }
}

- (void)modalAdWillAppear {
    if ([self.delegate respondsToSelector:@selector(customEventInterstitialWillPresent:)]) {
        [self.delegate customEventInterstitialWillPresent:self];
    }
}

- (void)modalAdDidAppear {
    // AdMod does not support the `Did Appear Event`
}

- (void)modalAdWillDisappear {
    if ([self.delegate respondsToSelector:@selector(customEventInterstitialWillDismiss:)]) {
        [self.delegate customEventInterstitialWillDismiss:self];
    }
}

- (void)modalAdDidDisappear {
    if ([self.delegate respondsToSelector:@selector(customEventInterstitialDidDismiss:)]) {
        [self.delegate customEventInterstitialDidDismiss:self];
    }
}

- (void)modalAdDidReceiveTapForDownload {
    if ([self.delegate respondsToSelector:@selector(customEventInterstitialWillLeaveApplication:)]) {
        [self.delegate customEventInterstitialWillLeaveApplication:self];
    }
}

#pragma mark - Server Parameters

- (void)parseServerParameter:(NSString *)serverParameter {
    
    if (![serverParameter isKindOfClass:NSString.class]) {
        NSLog(@"Parameters string is nil or not conform");
        return;
    }
    
    // Converting the string to NSDictionary if possible
    NSData * data = [serverParameter dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error = nil;
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"An error occurred while parsing parameters : %@", error.localizedDescription);
        return;
    }
    
    // Fetching necessary information in order to decide which ad unit we are showing
    if ([params isKindOfClass:NSDictionary.class]) {
        
        // Getting the type of the ad unit.
        NSString *type = [params objectForKey:@"type"];
        if ([type isKindOfClass:NSString.class]) {
            
            // Sushi
            if ([type isEqualToString:@"sushi"]) {
                _modalType = AFAdSDKModalTypeSushi;
            }
            
            // Uramaki
            else if ([type isEqualToString:@"uramaki"]) {
                _modalType = AFAdSDKModalTypeUraMaki;
            }
        }
        
        // Should we display the timer?
        NSNumber *timer = [params objectForKey:@"timer"];
        if ([timer isKindOfClass:NSNumber.class]) {
            _shouldShowTimer = [timer boolValue];
        }
    }
}

#pragma mark - Show Interstitials

- (void)showAppsfireInterstitialsFromRootViewController:(UIViewController *)rootViewController {
    
    if (![rootViewController isKindOfClass:UIViewController.class]) {
        return;
    }
    
    // If we don't have any available interstitial we skip the next lines.
    if ([AppsfireAdSDK isThereAModalAdAvailableForType:_modalType] != AFAdSDKAdAvailabilityYes) {
        return;
    }
    
    // Showing a timer before presenting the Ad.
    if (_shouldShowTimer) {
        
        [[[AppsfireAdTimerView alloc] initWithCountdownStart:AFAdMobCustomEventInterstitialTimerInterval] presentWithCompletion:^(BOOL accepted) {
            if (accepted) {
                [AppsfireAdSDK requestModalAd:_modalType withController:rootViewController];
            }
        }];
    }
    
    // Simply showing the Ad.
    else {
        [AppsfireAdSDK requestModalAd:_modalType withController:rootViewController];
    }
}


@end
