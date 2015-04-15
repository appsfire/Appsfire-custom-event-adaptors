/*!
 *  @header    AppsfireNativeAdAdapter.h
 *  @abstract  Appsfire Native Ad Adapter class.
 *  @version   1.7
 */

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPNativeAdAdapter.h"
#endif

@class AFNativeAd;

@interface AppsfireNativeAdAdapter : NSObject <MPNativeAdAdapter>

@property (nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithAFNativeAd:(AFNativeAd *)afNativeAd;

@end
