/*!
 *  @header    AppsfireNativeCustomEvent.m
 *  @abstract  Appsfire Native Custom Event class.
 *  @version   1.7
 */

#import "AppsfireNativeCustomEvent.h"
#import "AppsfireNativeAdAdapter.h"
// mopub
#import "MPNativeAd.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"
// appsfire sdk
#import "AppsfireSDK.h"
#import "AppsfireAdSDK.h"
#import "AFNativeAd.h"

@interface AppsfireNativeCustomEvent () <AppsfireAdSDKDelegate>

// check the availability of Ads
- (void)checkAvailabilityOfAds;

// misc
- (void)nativeAdCanBeDisplayed;
- (void)nativeAdCannotBeDisplayedWithError:(NSError *)error;

@end

@implementation AppsfireNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    
    // check if ads are available
    [self checkAvailabilityOfAds];
    
}

- (void)checkAvailabilityOfAds {
    
    NSError *error;
    AFAdSDKAdAvailability availability;
    
    // check ad availability
    availability = [AppsfireAdSDK isThereNativeAdAvailable];
    
    // act differently:
    switch (availability) {
            
        // we don't know yet
        case AFAdSDKAdAvailabilityPending:
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nativeAdsRefreshedAndAvailable) name:kAFSDKNativeAdsRefreshedAndAvailable object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nativeAdsRefreshedAndNotAvailable) name:kAFSDKNativeAdsRefreshedAndNotAvailable object:nil];
            break;
        }
            
        // we have ads
        case AFAdSDKAdAvailabilityYes:
        {
            [self nativeAdCanBeDisplayed];
            break;
        }
            
        // we don't have ads
        case AFAdSDKAdAvailabilityNo:
        {
            error = [NSError errorWithDomain:@"com.appsfire.sdk" code:AFSDKErrorCodeAdvertisingNoAd userInfo:@{NSLocalizedDescriptionKey: @"No Ads to display."}];
            [self nativeAdCannotBeDisplayedWithError:error];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKNativeAdsRefreshedAndAvailable object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKNativeAdsRefreshedAndNotAvailable object:nil];
    
}

#pragma mark - Appsfire Ad Delegate

- (void)nativeAdsRefreshedAndAvailable {
    
    // avoid more events
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKNativeAdsRefreshedAndAvailable object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKNativeAdsRefreshedAndNotAvailable object:nil];
    
    // let mopub know
    [self nativeAdCanBeDisplayed];
    
}

- (void)nativeAdsRefreshedAndNotAvailable {
    
    NSError *error;
    
    // avoid more events
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKNativeAdsRefreshedAndAvailable object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAFSDKNativeAdsRefreshedAndNotAvailable object:nil];
    
    //
    error = [NSError errorWithDomain:@"com.appsfire.sdk" code:AFSDKErrorCodeAdvertisingNoAd userInfo:@{NSLocalizedDescriptionKey : @"No Ads to display."}];
    
    // let mopub know
    [self nativeAdCannotBeDisplayedWithError:error];
    
}

#pragma mark - Misc

- (void)nativeAdCanBeDisplayed {
    
    NSError *error;
    AFNativeAd *nativeAd;
    AppsfireNativeAdAdapter *adAdapter;
    NSMutableArray *imageURLs;
    MPNativeAd *mopubNativeAd;
    
    // get native ad
    error = nil;
    nativeAd = [AppsfireAdSDK nativeAdWithError:&error];
    if (![nativeAd isKindOfClass:[AFNativeAd class]] || error != nil) {
        [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorNoInventory userInfo:nil]];
        return;
    }
    
    // create ad adapter
    adAdapter = [[AppsfireNativeAdAdapter alloc] initWithAFNativeAd:nativeAd];
    
    // mopub native ad
    mopubNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adAdapter];
    
    // get image urls
    imageURLs = [NSMutableArray array];
    if (nativeAd.iconURL != nil) {
        [imageURLs addObject:[NSURL URLWithString:nativeAd.iconURL]];
    }
    if (nativeAd.screenshotURL != nil) {
        [imageURLs addObject:[NSURL URLWithString:nativeAd.screenshotURL]];
    }
    
    // pre-cache images
    [super precacheImagesWithURLs:imageURLs completionBlock:^(NSArray *errors) {
        if (errors) {
            MPLogDebug(@"%@", errors);
            MPLogInfo(@"Error: data received was invalid.");
            [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:MoPubNativeAdsSDKDomain code:MPNativeAdErrorInvalidServerResponse userInfo:nil]];
        } else {
            [self.delegate nativeCustomEvent:self didLoadAd:mopubNativeAd];
        }
    }];
    
}

- (void)nativeAdCannotBeDisplayedWithError:(NSError *)error {
    
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
    
}

@end
