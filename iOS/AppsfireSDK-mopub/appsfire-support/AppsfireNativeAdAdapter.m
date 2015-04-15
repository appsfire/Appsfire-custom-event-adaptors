/*!
 *  @header    AppsfireNativeAdAdapter.m
 *  @abstract  Appsfire Native Ad Adapter class.
 *  @version   1.7
 */

#import "AppsfireNativeAdAdapter.h"
// mopub
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPLogging.h"
// appsfire
#import "AFNativeAd.h"

@interface AppsfireNativeAdAdapter () <AFNativeAdDelegate>

@property (nonatomic, strong) AFNativeAd *afNativeAd;

@end

@implementation AppsfireNativeAdAdapter

@synthesize properties = _properties;

- (instancetype)initWithAFNativeAd:(AFNativeAd *)afNativeAd {
    
    NSMutableDictionary *properties;
    
    if (self = [super init]) {
        
        //
        self.afNativeAd = afNativeAd;
        self.afNativeAd.delegate = self;
        
        //
        properties = [NSMutableDictionary dictionary];
        
        // title
        if (self.afNativeAd.title != nil) {
            [properties setObject:self.afNativeAd.title forKey:kAdTitleKey];
        }

        // body
        if (self.afNativeAd.tagline != nil) {
            [properties setObject:self.afNativeAd.tagline forKey:kAdTextKey];
        }

        // call to action
        if (_afNativeAd.callToAction != nil) {
            [properties setObject:_afNativeAd.callToAction forKey:kAdCTATextKey];
        }

        // icon url
        if (_afNativeAd.iconURL != nil) {
            [properties setObject:_afNativeAd.iconURL forKey:kAdIconImageKey];
        }

        // main image url
        if (self.afNativeAd.screenshotURL != nil) {
            [properties setObject:self.afNativeAd.screenshotURL forKey:kAdMainImageKey];
        }
        
        // star rating
        if (self.afNativeAd.starRating != nil) {
            [properties setObject:self.afNativeAd.starRating forKey:kAdStarRatingKey];
        }

        //
        _properties = properties;
        
    }
    return self;
    
}


#pragma mark - Mopub Native Ad Adapter

- (NSTimeInterval)requiredSecondsForImpression {
    
    return 0.0;
    
}

- (NSURL *)defaultActionURL {
    
    return nil;
    
}

- (BOOL)enableThirdPartyImpressionTracking {
    
    return YES;
    
}

- (BOOL)enableThirdPartyClickTracking {
    
    return YES;
    
}

- (void)willAttachToView:(UIView *)view {
    
    [self.afNativeAd connectViewForDisplay:view withClickableViews:nil];
    
}

- (void)didDetachFromView:(UIView *)view {
    
    [self.afNativeAd disconnectViewForDisplay];
    
}

#pragma mark - Appsfire Native Ad Delegate

- (UIViewController *)viewControllerForNativeAd:(AFNativeAd *)nativeAd {
    
    UIViewController *controller;
    
    //
    controller = [self.delegate viewControllerForPresentingModalView];
    if (![controller isKindOfClass:[UIViewController class]])
        MPLogWarn(@"Object for presenting the modal view is not an UIViewController. In-app overlay won't work.");
    
    //
    return controller;
    
}

- (void)nativeAdDidRecordImpression:(AFNativeAd *)nativeAd {

    if ([self.delegate respondsToSelector:@selector(nativeAdWillLogImpression:)]) {
        [self.delegate nativeAdWillLogImpression:self];
    } else {
        MPLogWarn(@"Delegate does not implement impression tracking callback. Impressions likely not being tracked.");
    }
    
}

- (void)nativeAdDidRecordClick:(AFNativeAd *)nativeAd {
    
    if ([self.delegate respondsToSelector:@selector(nativeAdDidClick:)]) {
        [self.delegate nativeAdDidClick:self];
    } else {
        MPLogWarn(@"Delegate does not implement click tracking callback. Clicks likely not being tracked.");
    }
    
}

@end
