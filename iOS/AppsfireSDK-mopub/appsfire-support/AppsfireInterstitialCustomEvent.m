/*!
 *  @header    AppsfireInterstitialCustomEvent.m
 *  @abstract  Appsfire Interstitial Custom Event class.
 *  @version   1.7
 */

#import "AppsfireInterstitialCustomEvent.h"
// appsfire sdk
#import "AppsfireAdSDK.h"
#import "AppsfireAdTimerView.h"

static NSTimeInterval const AppsfireInterstitialCustomEventTimerInterval = 3.0;

@interface AppsfireInterstitialCustomEvent () <AppsfireAdSDKDelegate, AFAdSDKModalDelegate>

@property (nonatomic, assign) AFAdSDKModalType modalType;
@property (nonatomic, assign) BOOL shouldShowTimer;
@property (nonatomic, assign, getter=isDelegateAlreadyNotified) BOOL delegateAlreadyNotified;

// parse and assign the modal type and timer values
- (void)parseInfoPayload:(NSDictionary *)info;

// show Appsfire interstitials if those are available
- (void)showAppsfireInterstitialsFromRootViewController:(UIViewController *)rootViewController;

// check the availability of Ads
- (void)checkAvailabilityOfAds;

// misc
- (void)interstitialDidLoad;
- (void)interstitialDidFailToLoadWithError:(NSError *)error;

@end

@implementation AppsfireInterstitialCustomEvent

#pragma mark - Ad Request

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    
    //
    _delegateAlreadyNotified = NO;
    _modalType = AFAdSDKModalTypeSushi;
    _shouldShowTimer = NO;
    
    // get custom values
    [self parseInfoPayload:info];
    
    // check if ads are available
    [self checkAvailabilityOfAds];
    
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    
    [self showAppsfireInterstitialsFromRootViewController:rootViewController];
    
}

- (void)checkAvailabilityOfAds {
    
    NSError *error;
    AFAdSDKAdAvailability availability;
    
    // check ad availability
    availability = [AppsfireAdSDK isThereAModalAdAvailableForType:_modalType];
    
    // act differently:
    switch (availability) {
            
        // we don't know yet
        case AFAdSDKAdAvailabilityPending:
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modalAdsRefreshedAndAvailable) name:kAFSDKModalAdsRefreshedAndAvailable object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modalAdsRefreshedAndNotAvailable) name:kAFSDKModalAdsRefreshedAndNotAvailable object:nil];
            break;
        }
            
        // we have ads
        case AFAdSDKAdAvailabilityYes:
        {
            [self interstitialDidLoad];
            break;
        }
            
        // we don't have ads
        case AFAdSDKAdAvailabilityNo:
        {
            error = [NSError errorWithDomain:@"com.appsfire.sdk" code:AFSDKErrorCodeAdvertisingNoAd userInfo:@{NSLocalizedDescriptionKey: @"No Ads to display."}];
            [self interstitialDidFailToLoadWithError:error];
            break;
        }
            
        default:
        {
            break;
        }
        
    }
    
}

#pragma mark - Dealloc

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKModalAdsRefreshedAndAvailable object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKModalAdsRefreshedAndNotAvailable object:nil];

}

#pragma mark - Appsfire Ad SDK Delegate

- (void)modalAdsRefreshedAndAvailable {
    
    // avoid more events
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKModalAdsRefreshedAndAvailable object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKModalAdsRefreshedAndNotAvailable object:nil];

    // let mopub know
    [self interstitialDidLoad];
    
}

- (void)modalAdsRefreshedAndNotAvailable {
    
    NSError *error;
    
    // avoid more events
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKModalAdsRefreshedAndAvailable object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKModalAdsRefreshedAndNotAvailable object:nil];

    //
    error = [NSError errorWithDomain:@"com.appsfire.sdk" code:AFSDKErrorCodeAdvertisingNoAd userInfo:@{NSLocalizedDescriptionKey : @"No Ads to display."}];
    
    // let mopub know
    [self interstitialDidFailToLoadWithError:error];
    
}

#pragma mark - Appsfire Modal Delegate

- (void)modalAdRequestDidFailWithError:(NSError *)error {
    
    [self interstitialDidFailToLoadWithError:error];
    
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
    
}

- (void)modalAdDidReceiveTapForDownload {
    
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEventDidReceiveTapEvent:)]) {
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    }
    
}

#pragma mark - Misc

- (void)interstitialDidLoad {
    
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)] && !self.isDelegateAlreadyNotified) {
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
        _delegateAlreadyNotified = YES;
    }
    
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)] && !self.isDelegateAlreadyNotified) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        _delegateAlreadyNotified = YES;
    }
    
}

#pragma mark - Parse the Info Payload

- (void)parseInfoPayload:(NSDictionary *)info {
    
    NSString *type;
    NSNumber *timer;
    
    // fetch necessary information in order to decide which ad unit we are showing
    if ([info isKindOfClass:NSDictionary.class]) {
        
        // get the type of the ad unit.
        type = [info objectForKey:@"type"];
        if ([type isKindOfClass:NSString.class]) {
            
            // sushi
            if ([type isEqualToString:@"sushi"]) {
                _modalType = AFAdSDKModalTypeSushi;
            }
            
            // uramaki
            else if ([type isEqualToString:@"uramaki"]) {
                _modalType = AFAdSDKModalTypeUraMaki;
            }
            
        }
        
        // display the timer?
        timer = [info objectForKey:@"timer"];
        if ([timer isKindOfClass:NSNumber.class]) {
            _shouldShowTimer = [timer boolValue];
        }
        
    }
    
}

#pragma mark - Show Interstitials

- (void)showAppsfireInterstitialsFromRootViewController:(UIViewController *)rootViewController {
    
    // check controller class
    if (![rootViewController isKindOfClass:UIViewController.class]) {
        return;
    }
    
    // check ad availability for specified format
    if ([AppsfireAdSDK isThereAModalAdAvailableForType:_modalType] != AFAdSDKAdAvailabilityYes) {
        return;
    }
    
    // show timer if needed
    if (_shouldShowTimer) {
        
        [[[AppsfireAdTimerView alloc] initWithCountdownStart:AppsfireInterstitialCustomEventTimerInterval] presentWithCompletion:^(BOOL accepted) {
            if (accepted) {
                [AppsfireAdSDK requestModalAd:_modalType withController:rootViewController withDelegate:self];
            }
        }];
    }
    
    // or just show ad
    else {
        
        [AppsfireAdSDK requestModalAd:_modalType withController:rootViewController withDelegate:self];
        
    }
    
}

@end
