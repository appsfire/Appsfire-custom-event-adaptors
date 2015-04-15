package com.appsfire.mediation;

import java.util.Arrays;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.appsfire.adUnitJAR.exceptions.AFAdAlreadyDisplayedException;
import com.appsfire.adUnitJAR.sdk.AFAdSDK;
import com.appsfire.adUnitJAR.sdk.AFAdSDK.AFAdSDKError;
import com.appsfire.adUnitJAR.sdk.AFAdSDK.AFAdSDKModalType;
import com.appsfire.adUnitJAR.sdk.AFAdSDK.AFSDKFeature;
import com.appsfire.adUnitJAR.sdk.AFAdSDKEventsDelegate;
import com.appsfire.adUnitJAR.sdkimpl.AFSDKFactory;
import com.appsfire.adUnitJAR.sdkimpl.DefaultAFAdSDK;
import com.google.ads.mediation.MediationAdRequest;
import com.google.ads.mediation.customevent.CustomEventInterstitial;
import com.google.ads.mediation.customevent.CustomEventInterstitialListener;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public class AdmobInterstitialAdapter implements CustomEventInterstitial,  AFAdSDKEventsDelegate {
	/** Tag for logging messages */
	public static final String CLASS_TAG = "AdmobInterstitialAdapter";
	
	/** Ad sdk instance */
	private static AFAdSDK adSdk;
	
	/** Activity context */
	private Context mContext;
	
	/** Custom event listener */
	private CustomEventInterstitialListener mListener;
	
    /*
     * MediationInterstitialAdapter implementation
     */
	
	public Class<AppsfireNetworkExtras> getAdditionalParametersType() {
		return AppsfireNetworkExtras.class;
	}

	public Class<AppsfireServerParameters> getServerParametersType() {
		return AppsfireServerParameters.class;
	}
	
	@Override
	public void requestInterstitialAd(CustomEventInterstitialListener listener,
			Activity activity, String label, String serverParameters, MediationAdRequest mediationAdRequest,
			Object customEventExtra) {
		mContext = activity;
		mListener = listener;
		
		// Get sdk key and debug on/off settings from the server json string set up on the Mopub backend
		
		Log.d (CLASS_TAG, "requestInterstitialAd");
		
    	adSdk = AFSDKFactory.getAFAdSDK();
    	adSdk.setEventsDelegate(this);
		mListener.onReceivedAd();
	}
	
	public void showInterstitial() {
		Log.d (CLASS_TAG, "showInterstitial");
		
		// Check if a modal ad of type Sushi is available
		if (adSdk.isAModalAdOfTypeAvailable(AFAdSDKModalType.AFAdSDKModalTypeSushi) && mContext != null) {
			try {
				// Request modal ad
        	    adSdk.requestModalAd(AFAdSDKModalType.AFAdSDKModalTypeSushi, mContext);			                        
			} catch (AFAdAlreadyDisplayedException e) {									
			}
		}
	}
	
	public void destroy() {
		Log.d (CLASS_TAG, "destroy");
		mContext = null;
		mListener = null;
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
		if (mContext != null && mListener != null)
			mListener.onReceivedAd();
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
	}
		
	@Override
	public void onModalAdPreDisplay() {
		// A modal ad is about to display
		Log.i (CLASS_TAG, "onModalAdPreDisplay");
		if (mContext != null && mListener != null)
			mListener.onPresentScreen();
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
    	new Thread() {
    		public void run() {
    			((DefaultAFAdSDK) adSdk).publishEvents();
    		}
    	}.run();
	}

	@Override
	public void onModalAdDismissed() {
		// A modal ad has closed
		Log.i (CLASS_TAG, "onModalAdDismissed");
		if (mContext != null && mListener != null)
			mListener.onDismissScreen();
	}

	@Override
	public void onLeaveApplication() {
		// Leaving application
		Log.i (CLASS_TAG,"onLeaveApplication");
		if (mContext != null && mListener != null)
			mListener.onLeaveApplication();
	}
}
