/*!
 *  @header    AFAdMobCustomEventInterstitial.m
 *  @abstract  Appsfire AdMob Interstitial Custom Event class.
 *  @version   1.4
 */

#import "AFAdMobCustomEventInterstitial.h"

// Appsfire SDK
#import "AppsfireAdSDK.h"
#import "AppsfireAdTimerView.h"

static NSTimeInterval const AFAdMobCustomEventInterstitialTimerInterval = 3.0;

@interface AFAdMobCustomEventInterstitial () <AppsfireAdSDKDelegate, AFAdSDKModalDelegate>

@property (nonatomic, assign) AFAdSDKModalType modalType;
@property (nonatomic, assign) BOOL shouldShowTimer;
@property (nonatomic, assign, getter=isDelegateAlreadyNotified) BOOL delegateAlreadyNotified;

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
    self.delegate = nil;
    [AppsfireAdSDK setDelegate:nil];
}

#pragma mark - GADCustomEventInterstitial

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
    
    // Variable init.
    _delegateAlreadyNotified = NO;
    
    // Default values
    _modalType = AFAdSDKModalTypeSushi;
    _shouldShowTimer = NO;
    
    // Getting custom values.
    [self parseServerParameter:serverParameter];
    
    // Check if ads are available.
    [self checkAdAvailability];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self showAppsfireInterstitialsFromRootViewController:rootViewController];
}

- (void)checkAdAvailability {
    
    // We need to know if we have available ads.
    AFAdSDKAdAvailability availability = [AppsfireAdSDK isThereAModalAdAvailableForType:_modalType];
    
    // Depending on the availability.
    switch (availability) {
            
        case AFAdSDKAdAvailabilityPending: {
            
            // Setting the delegate to receive availability events.
            [AppsfireAdSDK setDelegate:self];
            
        } break;
            
        case AFAdSDKAdAvailabilityYes: {
            [self interstitialDidLoad];
        } break;
            
        case AFAdSDKAdAvailabilityNo: {
            NSError *error = [NSError errorWithDomain:@"com.appsfire.sdk"
                                                 code:AFSDKErrorCodeAdvertisingNoAd
                                             userInfo:@{NSLocalizedDescriptionKey : @"No Ads to display."}];
            [self interstitialDidFailToLoadWithError:error];
        } break;
            
        default: {
        } break;
    }
}

#pragma mark - AppsfireAdSDKDelegate

- (void)modalAdsRefreshedAndAvailable {
    
    [self interstitialDidLoad];
    [AppsfireAdSDK setDelegate:nil];
}

- (void)modalAdsRefreshedAndNotAvailable {
    
    NSError *error = [NSError errorWithDomain:@"com.appsfire.sdk"
                                         code:AFSDKErrorCodeAdvertisingNoAd
                                     userInfo:@{NSLocalizedDescriptionKey : @"No Ads to display."}];
    
    [self interstitialDidFailToLoadWithError:error];
    [AppsfireAdSDK setDelegate:nil];
}

#pragma mark - AFAdSDKModalDelegate

- (void)modalAdRequestDidFailWithError:(NSError *)error {
    [self interstitialDidFailToLoadWithError:error];
}

- (void)modalAdWillAppear {
    
    if ([self.delegate respondsToSelector:@selector(customEventInterstitialWillPresent:)]) {
        [self.delegate customEventInterstitialWillPresent:self];
    }
}

- (void)modalAdDidAppear {
    
    // AdMod does not support this delegate event.
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

#pragma mark - Misc

- (void)interstitialDidLoad {
    
    if ([self.delegate respondsToSelector:@selector(customEventInterstitial:didReceiveAd:)] && !self.isDelegateAlreadyNotified) {
        [self.delegate customEventInterstitial:self didReceiveAd:nil];
        _delegateAlreadyNotified = YES;
    }
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(customEventInterstitial:didFailAd:)] && !self.isDelegateAlreadyNotified) {
        [self.delegate customEventInterstitial:self didFailAd:error];
        _delegateAlreadyNotified = YES;
    }
}

#pragma mark - Server Parameters

- (void)parseServerParameter:(NSString *)serverParameter {
    
    NSError *error;
    
    if (![serverParameter isKindOfClass:NSString.class]) {
        NSError *error = [NSError errorWithDomain:@"com.appsfire.sdk"
                                             code:AFSDKErrorCodeAdvertisingNoAd
                                         userInfo:@{NSLocalizedDescriptionKey : @"Parameters string is nil or does not conform."}];
        [self interstitialDidFailToLoadWithError:error];
        return;
    }
    
    // Converting the string to NSDictionary if possible
    NSData *data = [serverParameter dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        [self interstitialDidFailToLoadWithError:error];
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
                [AppsfireAdSDK requestModalAd:_modalType withController:rootViewController withDelegate:self];
            }
        }];
    }
    
    // Simply showing the Ad.
    else {
        [AppsfireAdSDK requestModalAd:_modalType withController:rootViewController withDelegate:self];
    }
}


@end
