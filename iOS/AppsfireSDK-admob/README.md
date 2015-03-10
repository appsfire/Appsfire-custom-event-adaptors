#Appsfire AdUnit and AdMob Mediation

Appsfire's AdUnit integration with AdMob is quite easy. AdMob provides a simple way with custom events to plug their SDK with our AdUnit.

##Quick Start
1. First you need to [**install the Appsfire SDK**](http://docs.appsfire.com/sdk/ios/integration-reference/Setup_Your_Project). If you are not familiar with it, you can take a look at the AdMob Mediation Demo project bundled in this package.

1. In your Xcode project, **import** the following files:
  - the appsfire sdk (folder `appsfire-sdk`)
  - the timer class called `AppsfireAdTimerView` (folder `appsfire-sdk-timer`)
  - the custom event class for admob called `AFAdMobCustomEventInterstitial` (folder `appsfire-custom-event-interstitial`)

  `AFAdMobCustomEventInterstitial` is a pre-configured class which will be automatically instantiated by the AdMob SDK. The procedure to integrate it is described in the [AdMob guide](https://developers.google.com/mobile-ads-sdk/docs/admob/mediation#ios-customevents).

1. On the AdMob web interface, **create a new network** in the Monetize section. A popup will be presented to you where you can pick a network, instead click on *Custom event* and enter `AFAdMobCustomEventInterstitial` in the *Class name* field. In the *Label* field enter something that will allow to easily identify the Appsfire AdUnit. In order to choose which Ad unit you want to display, you also need to add a *Parameter*. This is simply a JSON payload.

    You can specify the type of the Ad Unit with the `type` key and the 2 possible choices are:  
    - `sushi`  
    - `uramaki`

    You can also specify if you want to use the count down timer just before showing the Ad with the `timer` key which is should be `0` or `1`.

    Example of payload:  
    - Show the **Sushi** ad unit without the timer : `{"type":"sushi","timer":0}`  
    - Show the **Uramaki** ad unit with the timer : `{"type":"uramaki","timer":1}`

    If nothing is entered in the parameter, you will see the **Sushi** ad unit without the timer.

1. You should be good to go after these steps. To make sure, you can **run** the AdMob Mediation Demo project with you AdMob interstitial Unit Id and see a test interstitial.

**Note**: Please make sure to only allocate one interstitial at a time, otherwise you can end up having less events reported to AdMob.

##Release Notes

**1.5**
Updated the example project for Admob 7.0.
Updated the adapter to support new version of the Appsfire SDK (2.6.0).

**1.4**  
Updated the adapter to support new version of the Appsfire SDK (2.4.0).

**1.3**  
Fixed an issue where AdMob would not get properly notified of absence of ads after a `AFAdSDKAdAvailabilityPending` availability status.

**1.2**  
Improved notification of AdMob when no ads are available.

**1.1**  
Fixed a potential issue where the ads would not get triggered during the lifetime of an app.

**1.0**  
Initial release.
