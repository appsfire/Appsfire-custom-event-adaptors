package com.mopub.nativeads;

import java.util.Map;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.util.Log;

import com.appsfire.adUnitJAR.sdk.AFAdSDK;
import com.appsfire.adUnitJAR.sdk.AFAdSDKEventsDelegate;
import com.appsfire.adUnitJAR.sdk.AFAdSDK.AFAdSDKError;
import com.appsfire.adUnitJAR.sdk.AFNativeAd;
import com.mopub.nativeads.BaseForwardingNativeAd;
import com.mopub.nativeads.BaseForwardingNativeAd.NativeEventListener;
import com.mopub.nativeads.CustomEventNative;
import com.mopub.nativeads.NativeErrorCode;

/*
 * Appsfire native ads adapter for Mopub
 */
public class AppsfireNativeAd extends CustomEventNative implements AFAdSDKEventsDelegate, NativeEventListener  {
	/** Tag for logging messages */
	public static final String CLASS_TAG = "Appsfire.AppsfireNativeAd";
		
    /*
     * These keys are intended for MoPub internal use. Do not modify.
     */
    private static final String AF_SDK_KEY = "sdkKey";
    private static final String AF_IS_DEBUG = "isDebug";

    Context mContext;
    private CustomEventNativeListener mCustomEventNativeListener;
    AppsfireForwardingNativeAd mForwardingNativeAd;
    AFNativeAd mAFNativeAd;
    
	// Ad sdk instance
	private static AFAdSDK adSdk;
	
    public AppsfireNativeAd() {
    	Log.d (CLASS_TAG, "new AppsfireNativeAd");
    }
    
	@Override
    protected void loadNativeAd(final Context context,
            final CustomEventNativeListener customEventNativeListener,
            final Map<String, Object> localExtras,
            final Map<String, String> serverExtras) {
		Log.d (CLASS_TAG, "loadNativeAd");

		if (!(context instanceof Activity)) {
			Log.d (CLASS_TAG, "loadNativeAd: context isn't an Activity, fail");
			customEventNativeListener.onNativeAdFailed(NativeErrorCode.NATIVE_ADAPTER_CONFIGURATION_ERROR);
			return;
		}

		String sdkKey = null;
		boolean isDebug = false;

		if (extrasAreValid(serverExtras)) {
			sdkKey = serverExtras.get(AF_SDK_KEY);
			isDebug = serverExtras.get(AF_IS_DEBUG).equalsIgnoreCase("0") == false;  

			mContext = context;
            mCustomEventNativeListener = customEventNativeListener;
			mForwardingNativeAd = new AppsfireForwardingNativeAd(context, customEventNativeListener);
			mForwardingNativeAd.setNativeEventListener(this);
			
			Log.d (CLASS_TAG, "loadNativeAd: initialize SDK");
			adSdk = com.mopub.mobileads.AppsfireCommon.initializeAdSDK(context, sdkKey, isDebug);
			adSdk.addEventsDelegate(this);
			if (adSdk.numberOfNativeAdsAvailable() != 0) {
				Log.d (CLASS_TAG, "ad already available, load");
				onNativeAdAvailable();
			}
		}
		else {
			Log.d (CLASS_TAG, "loadNativeAd: missing server extras, fail");
			customEventNativeListener.onNativeAdFailed(NativeErrorCode.NATIVE_ADAPTER_CONFIGURATION_ERROR);			
		}
		
	}
	
    private boolean extrasAreValid(Map<String, String> extras) {
        return extras.containsKey(AF_SDK_KEY)
                && extras.containsKey(AF_IS_DEBUG);
    }
    
    static class AppsfireForwardingNativeAd extends BaseForwardingNativeAd {
    	AppsfireForwardingNativeAd(final Context context,
                final CustomEventNativeListener customEventNativeListener) {
    		Log.d (CLASS_TAG, "new AppsfireForwardingNativeAd");
        }    	
    }
    
    /*
     * AFAdSDKEventsDelegate implementation
     */

	@Override
	public void onEngageSDKInitialized() {
		// SDK initialized
		Log.i (CLASS_TAG, "onEngageSDKInitialized");
	}

	@Override
	public void onAdUnitInitialized() {
		// Ad unit initialized
		Log.i (CLASS_TAG, "onAdUnitInitialized");
	}

	
	@Override
	public void onAdsLoaded() {
		// Ads metadata downloaded
		Log.i (CLASS_TAG, "onAdsLoaded");
	}

	@Override
	public void onModalAdAvailable() {
		// A modal ad (sushi interstitial) is available
		Log.i (CLASS_TAG, "onModalAdAvailable");
	}
	
	@Override
	public void onInStreamAdAvailable() {
		// One or more in-stream (sashimi) ads are available
		Log.i (CLASS_TAG, "onInStreamAdAvailable");		
	}
		
	@Override
	public void onNativeAdAvailable() {
		// One or more native ads are available
		Log.i (CLASS_TAG, "onNativeAdAvailable");
		
		mAFNativeAd = adSdk.nativeAd (mContext);
		
		mForwardingNativeAd.setTitle(mAFNativeAd.getAppName());
		if (mAFNativeAd.getAppTagline() != null)
			mForwardingNativeAd.setText(mAFNativeAd.getAppTagline());
		mForwardingNativeAd.setCallToAction(mAFNativeAd.getCallToActionButtonText());
		mForwardingNativeAd.setIconImageUrl(mAFNativeAd.getIconURL());
		mForwardingNativeAd.setMainImageUrl(mAFNativeAd.getScreenshotURLs().get(0));
		Double rating = mAFNativeAd.getStarRating();
		if (rating > 0) mForwardingNativeAd.setStarRating(rating);
		mForwardingNativeAd.setClickDestinationUrl(mAFNativeAd.getDestinationURL());
		
		mCustomEventNativeListener.onNativeAdLoaded(mForwardingNativeAd);
	}
		
	@Override
	public void onModalAdPreDisplay() {
		// A modal ad is about to display
		Log.i (CLASS_TAG, "onModalAdPreDisplay");
	}

	@Override
	public void onModalAdDisplayed() {
		// A modal ad is displayed
		Log.i (CLASS_TAG, "onModalAdDisplayed");
	}

	@Override
	public void onModalAdFailedToDisplay(AFAdSDKError errCode) {
		// A modal ad failed to display
		Log.i (CLASS_TAG, "onModalAdFailedToDisplay");
	}

	@Override
	public void onModalAdPreDismiss() {
		// A modal ad is about to close
		Log.i (CLASS_TAG, "onModalAdPreDismiss");
	}

	@Override
	public void onModalAdDismissed() {
		// A modal ad has closed
		Log.i (CLASS_TAG, "onModalAdDismissed");
	}
	

	@Override
	public void onLeaveApplication() {
		// Leaving application
		Log.i (CLASS_TAG,"onLeaveApplication");
	}

	// NativeEventListener implementation
	
	@Override
	public void onAdImpressed() {
		Log.i (CLASS_TAG, "onAdImpressed");
		if (mAFNativeAd != null)
			mAFNativeAd.reportImpression();
	}

	@Override
	public void onAdClicked() {
		Log.i (CLASS_TAG, "onAdClicked");		
		if (mAFNativeAd != null)
			mAFNativeAd.reportClick();
	}
};
