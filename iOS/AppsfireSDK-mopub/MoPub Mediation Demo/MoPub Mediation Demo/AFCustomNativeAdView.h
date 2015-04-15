//
//  AFCustomNativeAdView.h
//  MoPub Mediation Demo
//
//  Created by Vincent on 13/04/2015.
//  Copyright (c) 2015 appsfire. All rights reserved.
//

#import <UIKit/UIView.h>
//
#import "MPNativeAdRendering.h"

@class AFNativeAd;

@interface AFCustomNativeAdView : UIView <MPNativeAdRendering>

@property (nonatomic, strong) AFNativeAd *nativeAd;

@end
