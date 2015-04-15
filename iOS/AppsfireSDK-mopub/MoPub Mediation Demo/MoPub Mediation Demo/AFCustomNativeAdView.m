//
//  AFCustomNativeAdView.m
//  MoPub Mediation Demo
//
//  Created by Vincent on 13/04/2015.
//  Copyright (c) 2015 appsfire. All rights reserved.
//

#import "AFCustomNativeAdView.h"
// objects
#import "AFNativeAd.h"
// views
#import "AFAdSDKAdBadgeView.h"

@import UIKit.UILabel;
@import UIKit.UIImageView;
@import UIKit.NSStringDrawing;
@import UIKit.NSAttributedString;
@import QuartzCore.QuartzCore;

@interface AFCustomNativeAdView ()

// title label
@property (nonatomic, strong) UILabel *titleLabel;

// tagline label
@property (nonatomic, strong) UILabel *taglineLabel;

// icon image
@property (nonatomic, strong) UIImageView *iconImageView;

// call-to-action label
@property (nonatomic, strong) UILabel *ctaLabel;

// badge view
@property (nonatomic, strong) AFAdSDKAdBadgeView *badgeView;

@end

@implementation AFCustomNativeAdView

- (id)init {
    
    //
    if ((self = [super init]) == nil)
        return nil;
    
    //
    self.backgroundColor = [UIColor whiteColor];
    
    // title label
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setTextColor:[UIColor blackColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]];
    [self.titleLabel setNumberOfLines:2];
    [self addSubview:self.titleLabel];
    
    // tagline label
    self.taglineLabel = [[UILabel alloc] init];
    [self.taglineLabel setTextColor:[UIColor blackColor]];
    [self.taglineLabel setBackgroundColor:[UIColor clearColor]];
    [self.taglineLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    [self.taglineLabel setNumberOfLines:2];
    [self addSubview:self.taglineLabel];
    
    // call-to-action label
    self.ctaLabel = [[UILabel alloc ] init];
    [self.ctaLabel setBackgroundColor:[UIColor clearColor ]];
    [self.ctaLabel setTextColor:[UIColor darkGrayColor]];
    [self.ctaLabel setTextAlignment:NSTextAlignmentCenter];
    [self.ctaLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0]];
    [self.ctaLabel.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.ctaLabel.layer setBorderWidth:1.0];
    [self.ctaLabel.layer setCornerRadius:4.0];
    [self addSubview:self.ctaLabel];
    
    // icon image
    self.iconImageView = [[UIImageView alloc ] initWithFrame:CGRectMake(0.0, 0.0, 70.0, 70.0)];
    [self.iconImageView.layer setMasksToBounds:YES];
    [self.iconImageView.layer setCornerRadius:CGRectGetWidth(self.iconImageView.frame)/5.4];
    [self addSubview:self.iconImageView];
    
    // appsfire badge view
    self.badgeView = [[AFAdSDKAdBadgeView alloc] init];
    self.badgeView.styleMode = AFAdSDKAdBadgeStyleModeDark;
    [self addSubview:self.badgeView];
    
    //
    [self clearAd];
    
    //
    return self;
    
}

- (void)dealloc {
    
    self.titleLabel = nil;
    self.taglineLabel = nil;
    self.ctaLabel = nil;
    self.iconImageView = nil;
    self.badgeView = nil;
    
}

- (void)layoutSubviews {
    
    CGRect iconImageFrame;
    CGRect titleLabelFrame;
    CGRect taglineLabelFrame;
    CGRect ctaLabelFrame;
    CGRect appsfireBadgeFrame;
    CGFloat contentTotalHeight, componentsSpacing;
    
    //
    [self.ctaLabel sizeToFit];
    
    //
    componentsSpacing = 6.0;
    titleLabelFrame = CGRectZero;
    taglineLabelFrame = CGRectZero;
    ctaLabelFrame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.ctaLabel.frame) + 12.0, CGRectGetHeight(self.ctaLabel.frame) + 4.0);
    
    // define icon frame
    iconImageFrame = CGRectMake(15.0, 0.0, 70.0, 70.0);
    iconImageFrame.origin.y = floor(CGRectGetHeight(self.frame) / 2.0 - CGRectGetHeight(iconImageFrame) / 2.0);
    
    // define appsfire badge frame
    appsfireBadgeFrame = CGRectMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.badgeView.frame) - 5.0, 5.0, CGRectGetWidth(self.badgeView.frame), CGRectGetHeight(self.badgeView.frame));
    
    // calculate height of title
    ctaLabelFrame.origin.x = titleLabelFrame.origin.x = CGRectGetMaxX(iconImageFrame) + 10.0;
    titleLabelFrame.size.width = CGRectGetWidth(self.frame) - titleLabelFrame.origin.x - 8.0 - 15.0;
    titleLabelFrame.size.height = [self stringSizeOfText:self.titleLabel.text withFont:self.titleLabel.font constrainedToSize:CGSizeMake(titleLabelFrame.size.width, self.titleLabel.font.lineHeight * 2) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    // calculate height of tagline
    if (self.taglineLabel.text.length > 0) {
        taglineLabelFrame.origin.x = titleLabelFrame.origin.x;
        taglineLabelFrame.size.width = CGRectGetWidth(titleLabelFrame);
        taglineLabelFrame.size.height = [self stringSizeOfText:self.taglineLabel.text withFont:self.taglineLabel.font constrainedToSize:CGSizeMake(taglineLabelFrame.size.width, self.taglineLabel.font.lineHeight * 2) lineBreakMode:NSLineBreakByWordWrapping].height;
    }
    
    // calculate total height (title + download)
    contentTotalHeight = CGRectGetHeight(titleLabelFrame) + componentsSpacing + CGRectGetHeight(ctaLabelFrame);
    if (!CGRectIsEmpty(taglineLabelFrame)) {
        contentTotalHeight += CGRectGetHeight(taglineLabelFrame) + componentsSpacing;
    }
    
    // adjust the title/download y
    titleLabelFrame.origin.y = floor(CGRectGetHeight(self.frame) / 2.0 - contentTotalHeight / 2.0);
    if (!CGRectIsEmpty(taglineLabelFrame)) {
        taglineLabelFrame.origin.y = CGRectGetMaxY(titleLabelFrame) + componentsSpacing;
        ctaLabelFrame.origin.y = CGRectGetMaxY(taglineLabelFrame) + componentsSpacing;
    }
    else {
        ctaLabelFrame.origin.y = CGRectGetMaxY(titleLabelFrame) + componentsSpacing;
    }
    
    // set frames
    [self.iconImageView setFrame:iconImageFrame];
    [self.titleLabel setFrame:titleLabelFrame];
    [self.taglineLabel setFrame:taglineLabelFrame];
    [self.ctaLabel setFrame:ctaLabelFrame];
    [self.badgeView setFrame:appsfireBadgeFrame];
    
}

#pragma mark - Native Ad Rendering Protocol

- (void)clearAd {
    
    // update components
    self.titleLabel.text = @"title label";
    self.taglineLabel.text = @"tagline label";
    self.ctaLabel.text = @"call to action label";
    self.iconImageView.image = nil;
    
    // refresh layout
    [self setNeedsLayout];
    
}

- (void)layoutAdAssets:(MPNativeAd *)adObject {
    
    // update components
    [adObject loadIconIntoImageView:self.iconImageView];
    [adObject loadTitleIntoLabel:self.titleLabel];
    [adObject loadTextIntoLabel:self.taglineLabel];
    [adObject loadCallToActionTextIntoLabel:self.ctaLabel];

    // refresh layout
    [self setNeedsLayout];
    
}

#pragma mark - String Size Helper

- (CGSize)stringSizeOfText:(NSString *)text withFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    
    CGSize boundingSize;
    NSDictionary *attributes;
    NSMutableParagraphStyle *paragrapheStyle;
    
    //
    if (![text isKindOfClass:[NSString class]])
        return CGSizeZero;
    
    // sanity check on the font
    if (![font isKindOfClass:[UIFont class]])
        font = [UIFont systemFontOfSize:12.0];
    
    // on iOS6- we use the legacy method
    if ([ text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:) ]) {
        
        return [text sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
        
    }
    
    // on iOS7+ we use the new method
    else {
        
        // paraphe style
        paragrapheStyle = [[NSMutableParagraphStyle alloc] init];
        paragrapheStyle.lineBreakMode = lineBreakMode;
        
        // attributes
        attributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragrapheStyle};
        
        // get the size of the string
        boundingSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
        // but the previous method won't return a rounded integer
        // so we need to do it ourselves
        boundingSize.width = fmin(ceil(boundingSize.width), size.width);
        boundingSize.height = fmin(ceil(boundingSize.height), size.height);
        
        return boundingSize;
        
    }
    
}

@end
