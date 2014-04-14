#Appsfire AdUnit and AdMob Mediation

Appsfire's AdUnit integration with AdMob is quite easy. AdMob provides a simple way with custom events to plug their SDK with our AdUnit.

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

## Quick Start
1. First you need to **install the Appsfire SDK** in order to use the Appsfire AdUnit. If you are not familiar with it, you can take a look at the AdMob Mediation Demo project bundled in this package.

2. In your Xcode project, **import** the two following files : `AFAdMobCustomEventInterstitial.h` and `AFAdMobCustomEventInterstitial.m`. This is the pre-configured class which will be automatically instantiated by the AdMob SDK. The procedure to implement it is described in the [AdMob guide](https://developers.google.com/mobile-ads-sdk/docs/admob/mediation#ios-customevents).

3. On the AdMob web interface, **create a new network** in the Monetize section. A popup will be presented to you where you can pick a network, instead click on *Custom event* and enter `AFAdMobCustomEventInterstitial` in the *Class name* field. In the *Label* field enter something that will allow to easily indentify the Appsfire AdUnit. In order to choose which Ad unit you want to display, you also need to add a *Parameter*. This is simply a JSON payload.

    You can specify the type of the Ad Unit with the `type` key and the 2 possible choices are:  
    - `sushi`  
    - `uramaki`

    You can also specify if you want to use the count down timer just before showing the Ad with the `timer` key which is should be `0` or `1`.

    Example of payload:  
    - Show the **Sushi** ad unit without the timer : `{"type":"sushi","timer":0}`  
    - Show the **Uramaki** ad unit with the timer : `{"type":"uramaki","timer":1}`

    If nothing is entered in the parameter, you will see the **Sushi** ad unit without the timer.

4. You should be good to go after these steps. To make sure, you can **run** the AdMob Mediation Demo project with you AdMob interstitial Unit Id and see a test interstitial.

**Note**: Please make sure to only allocate one interstitial at a time, otherwise you can end up having less events reported to AdMob.

##Release Notes

**1.3**  
Fixed an issue where AdMob would not get properly notified of absence of ads after a `AFAdSDKAdAvailabilityPending` availability status.

**1.2**  
Improved notification of AdMob when no ads are available.

**1.1**  
Fixed a potential issue where the ads would not get triggered during the lifetime of an app.

**1.0**  
Initial release.
