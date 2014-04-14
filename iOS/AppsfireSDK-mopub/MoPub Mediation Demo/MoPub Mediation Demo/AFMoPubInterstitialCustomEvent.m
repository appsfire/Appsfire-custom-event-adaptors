/*!
 *  @header    AFMoPubInterstitialCustomEvent.m
 *  @abstract  Appsfire MoPub Interstitial Custom Event class.
 *  @version   1.4
 */

#import "AFMoPubInterstitialCustomEvent.h"

// Appsfire SDK
#import "AppsfireAdSDK.h"
#import "AppsfireAdTimerView.h"

static NSTimeInterval const AFMoPubInterstitialCustomEventAdCheckInterval = 1.0;
static NSTimeInterval const AFMoPubInterstitialCustomEventTimerInterval = 3.0;
static NSUInteger const AFMoPubInterstitialCustomEventAdCheckTimeout = 30;

@interface AFMoPubInterstitialCustomEvent () <AppsfireAdSDKDelegate>

@property (nonatomic, assign) AFAdSDKModalType modalType;
@property (nonatomic, assign) NSTimer *adCheckTimer;
@property (nonatomic, assign) BOOL shouldShowTimer;
@property (nonatomic, assign, getter=isDelegateAlreadyNotified) BOOL delegateAlreadyNotified;
@property (nonatomic, assign) NSUInteger adCheckCount;

// Parses and assigns the modal type and timer values.
- (void)parseInfoPayload:(NSDictionary *)info;

// Shows Appsfire interstitials if those are available.
- (void)showAppsfireInterstitialsFromRootViewController:(UIViewController *)rootViewController;

// Checks the availability of Ads.
- (void)checkAdAvailability;

@end

@implementation AFMoPubInterstitialCustomEvent

#pragma mark - Ad Request

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    
    // Variable init.
    _adCheckCount = 0;
    _delegateAlreadyNotified = NO;
    
    // Default values
    _modalType = AFAdSDKModalTypeSushi;
    _shouldShowTimer = NO;
    
    // Getting custom values.
    [self parseInfoPayload:info];
    
    // Specify the delegate to handle various interactions with the Appsfire Ad SDK.
    [AppsfireAdSDK setDelegate:self];
    
    // Tells Ad SDK to prepare, this method is automatically called during a modal ad request.
    [AppsfireAdSDK prepare];
    
    // Check if ads are available.
    [self checkAdAvailability];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [self showAppsfireInterstitialsFromRootViewController:rootViewController];
}

- (void)checkAdAvailability {
    
    // Cancel any running timer.
    [_adCheckTimer invalidate], _adCheckTimer = nil;
    
    // Timeout failsafe.
    if (_adCheckCount >= AFMoPubInterstitialCustomEventAdCheckTimeout) {
        
        // We consider having no ads from now.
        if ([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
            NSError *error = [NSError errorWithDomain:@"com.appsfire.sdk" code:AFSDKErrorCodeAdvertisingNoAd userInfo:@{NSLocalizedDescriptionKey : @"No Ads to display."}];
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        }
    }
    
    // We need to know if we have available ads.
    AFAdSDKAdAvailability availability = [AppsfireAdSDK isThereAModalAdAvailableForType:_modalType];
    
    // Depending on the availability.
    switch (availability) {
            
            // If we are in a pending situation we fire a timer to retry every second.
        case AFAdSDKAdAvailabilityPending: {
            _adCheckTimer = [NSTimer scheduledTimerWithTimeInterval:AFMoPubInterstitialCustomEventAdCheckInterval target:self selector:@selector(checkAdAvailability) userInfo:nil repeats:NO];
        } break;
            
            // If we have ads we inform the delegate.
        case AFAdSDKAdAvailabilityYes: {
            if ([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)] && !self.isDelegateAlreadyNotified) {
                [self.delegate interstitialCustomEvent:self didLoadAd:nil];
                
                // We prevent from notifying the delegate twice.
                _delegateAlreadyNotified = YES;
            }
        } break;
            
            // If we have no ads we inform the delegate.
        case AFAdSDKAdAvailabilityNo: {
            if ([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
                NSError *error = [NSError errorWithDomain:@"com.appsfire.sdk" code:AFSDKErrorCodeAdvertisingNoAd userInfo:@{NSLocalizedDescriptionKey : @"No Ads to display."}];
                [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
            }
        } break;
            
        default: {
        } break;
    }
    
    _adCheckCount++;
}

#pragma mark - AppsfireAdSDKDelegate

- (void)modalAdIsReadyForRequest {
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)] && !self.isDelegateAlreadyNotified) {
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
        
        // We prevent from notifying the delegate twice.
        _delegateAlreadyNotified = YES;
    }
}

- (void)modalAdRequestDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

- (void)modalAdWillAppear {
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEventWillAppear:)]) {
        [self.delegate interstitialCustomEventWillAppear:self];
    }
}

- (void)modalAdDidAppear {
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEventDidAppear:)]) {
        [self.delegate interstitialCustomEventDidAppear:self];
    }
}

- (void)modalAdWillDisappear {
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEventWillDisappear:)]) {
        [self.delegate interstitialCustomEventWillDisappear:self];
    }
}

- (void)modalAdDidDisappear {
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEventDidDisappear:)]) {
        [self.delegate interstitialCustomEventDidDisappear:self];
    }
    
    // Cancel any running timer.
    [_adCheckTimer invalidate], _adCheckTimer = nil;
    
    // Setting the delegate to `nil` here because we don't know when the object is dealloaced.
    [AppsfireAdSDK setDelegate:nil];
}

- (void)modalAdDidReceiveTapForDownload {
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEventDidReceiveTapEvent:)]) {
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    }
}

#pragma mark - Parsing the Info

- (void)parseInfoPayload:(NSDictionary *)info {
    
    // Fetching necessary information in order to decide which ad unit we are showing
    if ([info isKindOfClass:NSDictionary.class]) {
        
        // Getting the type of the ad unit.
        NSString *type = [info objectForKey:@"type"];
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
        NSNumber *timer = [info objectForKey:@"timer"];
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
        
        [[[AppsfireAdTimerView alloc] initWithCountdownStart:AFMoPubInterstitialCustomEventTimerInterval] presentWithCompletion:^(BOOL accepted) {
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
