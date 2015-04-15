package com.mopub.mobileads;

import java.util.Arrays;

import android.content.Context;
import android.util.Log;

import com.appsfire.adUnitJAR.sdk.AFAdSDK;
import com.appsfire.adUnitJAR.sdk.AFAdSDK.AFSDKFeature;
import com.appsfire.adUnitJAR.sdkimpl.AFSDKFactory;

public class AppsfireCommon {
	/** Tag for logging messages */
	public static String CLASS_TAG = "Appsfire.AppsfireCommon";
	
	// Ad sdk instance
	private static AFAdSDK adSdk;

	// Initialize Appsfire SDK 
	
	public static AFAdSDK initializeAdSDK (Context context, String sdkKey, boolean isDebug) {
        if (adSdk == null) {
        	// Initialize SDK
        	Log.d (CLASS_TAG, "loadInterstitial: initialize Appsfire SDK");
        	adSdk = AFSDKFactory.getAFAdSDK().
			        setFeatures(Arrays.asList(AFSDKFeature.AFSDKFeatureMonetization)).
					setAPIKey(sdkKey).
					setDebugModeEnabled(isDebug);
        	adSdk.prepare(context);
        }
        
        return adSdk;		
	}	
};
