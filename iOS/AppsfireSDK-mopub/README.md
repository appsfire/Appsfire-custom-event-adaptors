#Appsfire AdUnit and MoPub Mediation

Appsfire's AdUnit integration with MoPub is quite easy. MoPub provides a simple way with custom events to plug their SDK with our AdUnit.

## Getting Started with Appsfire
The Appsfire iOS SDK is the cornerstone of the Appsfire network.

It provides the functionalities for monetizing your mobile application: it facilitates inserting native mobile ads into you application using native APIs. You can choose one of our ad units (Sushi, Uramaki).

It also helps you engage with your users by sending push and in-app notifications.

- Please visit our [website](http://appsfire.com) to learn more about our ad units and products.<br />
- Please visit our [online documentation](http://docs.appsfire.com/sdk/ios/integration-reference/Introduction) to learn how to integrate our SDK into your app.<br />
- Check out the full [API specification](http://docs.appsfire.com/sdk/ios/api-reference/) to have a detailed understanding of our SDK.

## Installation

In order to get started, please be sure you've done the following:

1. Registered on [Appsfire website](http://www.appsfire.com/) and accepted our Terms Of Use
2. Registered your app on our [Dashboard](http://dashboard.appsfire.com/) and generated an SDK key for your app
3. Grabbed our latest version of the SDK, either using CocoaPods, or downloading the SDK from our [Dashboard](http://dashboard.appsfire.com/app/doc)

##Quick Start
1. First you **need** to install the Appsfire SDK in order to use the Appsfire AdUnit. If you are not familiar with it, you can take a look at the MoPub Mediation Demo project bundled in this package.

2. In your Xcode project, **import** the two following files : `AFMoPubInterstitialCustomEvent.h` and `AFMoPubInterstitialCustomEvent.m`. This is the pre-configured class which will be automatically instantiated by the MoPub SDK. The procedure to implement it is described in the [MoPub wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Custom-Events#quick-start-for-interstitials).

3. On the MoPub web interface, create a network with the *"Custom Native Network"* type. Place the class name `AFMoPubInterstitialCustomEvent` in the *Custom Event Class* column under the *Set Up Your Inventory* section.

    In order to choose which Ad unit you want to display, you also need to add a *Custom Event Class Data*, the field next to the *Custom Event Class* one. This is simply a JSON payload.

    You can specify the type of the Ad Unit with the `type` key and the 2 possible choices are:  
    - `sushi`  
    - `uramaki`

    You can also specify if you want to use the count down timer just before showing the Ad with the `timer` key which is should be `0` or `1`.

    Example of payload:  
    - Show the **Sushi** ad unit without the timer : `{"type" : "sushi", "timer" : 0}`  
    - Show the **Uramaki** ad unit with the timer : `{"type" : "uramaki", "timer" : 1}`  

##Release Notes

**1.3**  
Fixed an issue where MoPub would not get properly notified of absence of ads after a `AFAdSDKAdAvailabilityPending` availability status.

**1.2**  
Improved notification of MoPub when no ads are available.

**1.1**  
Fixed a potential issue where the ads would not get triggered during the lifetime of an app.

**1.0**  
Initial release.
