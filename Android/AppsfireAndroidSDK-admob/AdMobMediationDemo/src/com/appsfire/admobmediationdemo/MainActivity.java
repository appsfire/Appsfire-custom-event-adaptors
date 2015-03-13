package com.appsfire.admobmediationdemo;

import java.util.Arrays;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.appsfire.adUnitJAR.sdk.AFAdSDK;
import com.appsfire.adUnitJAR.sdk.AFAdSDK.AFSDKFeature;
import com.appsfire.adUnitJAR.sdkimpl.AFSDKFactory;
import com.google.android.gms.ads.*;

/**
 * Sample activity
 */

public class MainActivity extends Activity {
	// Tag for logging messages
	public static final String CLASS_TAG = "AFadmobmediationdemo";
	
	// Admob ad unit ID in demo app
	private static final String ADMOB_ADUNIT_ID = "ca-app-pub-9559125671393639/8568170309";
	
	// Admob interstitial
	private InterstitialAd mInterstitial;
	
	// Appsfire App key
	private static final String YOUR_API_KEY = "F8E8C46EF05A02959E455019A0B8C558";
	
	// Appsfire App secret
	private static final String YOUR_API_SECRET = "aeb1128780d3669b545cf7beb3ea0386";
	
	// true for Appsfire debug mode, false for production mode (set to false when distributing your app)
	private static final Boolean IS_AFADSDK_DEBUG = true;

	// Create instance of the Appsfire ad SDK (required)
	private static AFAdSDK adSdk = AFSDKFactory.getAFAdSDK().
												setAPIKey(YOUR_API_KEY).
												setAPISecret(YOUR_API_SECRET).
												setFeatures(Arrays.asList(AFSDKFeature.AFSDKFeatureEngage, AFSDKFeature.AFSDKFeatureMonetization)).
												setDebugModeEnabled(IS_AFADSDK_DEBUG);
	
	// Create activity
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Bring up Appsfire SDK (required)
    	adSdk.prepare(this);
		
		// Set main layout as content
		setContentView(R.layout.activity_main);
		
		// Create the interstitial.
		mInterstitial = new InterstitialAd(this);
		mInterstitial.setAdUnitId(ADMOB_ADUNIT_ID);
		mInterstitial.setAdListener(new AdListener () {
			@Override
			public void onAdClosed() {
				AdRequest adRequest = new AdRequest.Builder().build();
				mInterstitial.loadAd(adRequest);
			}
		});

	    // Create ad request.
	    AdRequest adRequest = new AdRequest.Builder().build();
	    
	    // Begin loading interstitial.
	    mInterstitial.loadAd(adRequest);
	    
		// Add click handler to "show Admob Interstitial ad" button
		Button actionButton = (Button) findViewById(R.id.show_admob_button);
		final Activity activity = this;
		Log.d (CLASS_TAG, "actionButton = " + actionButton);
		actionButton.setOnClickListener (new Button.OnClickListener () {
		    public void onClick(View v) {
		    	 if (mInterstitial.isLoaded()) {
		    		 Log.d (CLASS_TAG, "Show interstitial...");
		    		 mInterstitial.show();
		 	      }
				else {
					// Interstitial is still loading
	                Toast toastInstance = Toast.makeText (activity, "The Admob interstitial is still loading...", Toast.LENGTH_LONG);				                
	                toastInstance.show ();																
				}
		    	
		    }
		});			   			
	}
}
