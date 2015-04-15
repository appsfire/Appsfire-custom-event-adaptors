# Appsfire and MoPub Mediation

Appsfire integration with MoPub is quite easy. MoPub provides a simple way with custom events to plug their SDK with our AdUnit.

**We currently support two Ad Unit**:

* "Interstitial" (aka Fullscreen) via the class `AppsfireInterstitialCustomEvent`
* "Native Ad" via the class `AppsfireNativeCustomEvent`



## Quick Start
1. First you need to [**install the Appsfire SDK**](http://docs.appsfire.com/sdk/ios/integration-reference/Setup_Your_Project). If you are not familiar with it, you can take a look at the MoPub Mediation Demo project bundled in this package.

1. In your Xcode project, **import** the following files :
  - the appsfire sdk (folder `appsfire-sdk`)
  - the custom event classes (folder `appsfire-support`)
  - the timer class called `AppsfireAdTimerView` (folder `appsfire-sdk-timer`)

  `AppsfireInterstitialCustomEvent` and `AppsfireNativeCustomEvent` are a pre-configured classes which will be automatically instantiated by the MoPub SDK. The procedure to implement it is described in the [MoPub wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Custom-Events#quick-start-for-interstitials).

1. On the MoPub web interface, create a network with the *"Custom Native Network"* type. Place the class name `AppsfireInterstitialCustomEvent` in the *Custom Event Class* column for the "Fullscreen" adunit. And place the class name `AppsfireNativeCustomEvent` in the *Custom Event Class* column for the "Native" adunit.

1. For the "Fullscreen" adunit, you can choose which format you want to display. You have to add some something in *Custom Event Class Data*, the field next to the *Custom Event Class* one. This is simply a JSON payload.

  You can specify the type of the Ad Unit with the `type` key and the 2 possible choices are:  
    - `sushi`  
    - `uramaki`

  You can also specify if you want to use the count down timer just before showing the Ad with the `timer` key which is should be `0` or `1`.

    Example of payload:  
    - Show the **Sushi** ad unit without the timer : `{"type" : "sushi", "timer" : 0}`  
    - Show the **Uramaki** ad unit with the timer : `{"type" : "uramaki", "timer" : 1}`  

**Note**: Please make sure to only allocate one interstitial at a time, otherwise you can end up having less events reported to MoPub.

## Release Notes

**1.7**  
Updated the example project for MoPub 3.6.  
Renamed the class of the interstitial custom event (from `AFMoPubInterstitialCustomEvent` to `AppsfireInterstitialCustomEvent`).  
Added the classes `AppsfireNativeCustomEvent` and `AppsfireNativeAdAdapter` for the Native Ad mediation.

**1.6**  
Updated the example project for MoPub 3.4.
Updated the adapter to support new version of the Appsfire SDK (2.6.0).

**1.5**  
Updated the adapter to support new version of the Appsfire SDK (2.4.0).

**1.4**  
Fixed an issue when successively allocating several interstitials and where the Appsfire SDK would not properly forward events to MoPub.

**1.3**  
Fixed an issue where MoPub would not get properly notified of absence of ads after a `AFAdSDKAdAvailabilityPending` availability status.

**1.2**  
Improved notification of MoPub when no ads are available.

**1.1**  
Fixed a potential issue where the ads would not get triggered during the lifetime of an app.

**1.0**  
Initial release.
