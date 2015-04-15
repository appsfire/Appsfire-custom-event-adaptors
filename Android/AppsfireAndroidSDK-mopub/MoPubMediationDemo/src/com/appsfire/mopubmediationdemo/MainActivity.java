package com.appsfire.mopubmediationdemo;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.appsfire.mopubmediationdemo.R;
import com.mopub.mobileads.MoPubErrorCode;
import com.mopub.mobileads.MoPubInterstitial;
import com.mopub.mobileads.MoPubInterstitial.InterstitialAdListener;

/**
 * Sample activity
 */

public class MainActivity extends Activity implements InterstitialAdListener {	
	// Tag for logging messages
	public static final String CLASS_TAG = "Appsfire.MainActivity";
	
	// Mopub Ad Unit ID
	private static final String MOPUB_AD_UNIT_ID = "fca6ab80352d4af3b04e8772f6deb974";
	
	// Mopub interstitial
	private MoPubInterstitial mInterstitial;
	
	// Create activity
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Log.d (CLASS_TAG, "onCreate");
		
		super.onCreate(savedInstanceState);

		// Set main layout as content
		setContentView(R.layout.activity_main);
		
		// Initialize SDK
		mInterstitial = new MoPubInterstitial(this, MOPUB_AD_UNIT_ID);
		mInterstitial.setTesting(true);
        mInterstitial.setInterstitialAdListener(this);
        mInterstitial.load();
        
		// Add click handler to "show Mopub Interstitial ad" button
		Button actionButton = (Button) findViewById(R.id.show_sushi_button);
		final Activity activity = this;
		actionButton.setOnClickListener (new Button.OnClickListener () {
		    public void onClick(View v) {
		    	if (mInterstitial.isReady()) {
		    		// Show interstitial
			    	mInterstitial.show();
				}
				else {
					// Interstitial is still loading
	                Toast toastInstance = Toast.makeText (activity, "The Mopub interstitial is still loading...", Toast.LENGTH_LONG);				                
	                toastInstance.show ();																
				}
		    	
		    }
		});

	}

	// Destroy activity
	
	@Override
    protected void onDestroy() {
        mInterstitial.destroy();
        super.onDestroy();
    }
	
	// InterstitialAdListener methods
    @Override
    public void onInterstitialLoaded(MoPubInterstitial interstitial) {
    	Log.d (CLASS_TAG, "Mopub onInterstitialLoaded");
        if (interstitial.isReady()) {
        	Log.d (CLASS_TAG, "Mopub: interstitial is ready");
        }
    }

    @Override
    public void onInterstitialFailed(MoPubInterstitial interstitial, MoPubErrorCode errorCode) {
    	Log.d (CLASS_TAG, "Mopub onInterstitialFailed: " + errorCode.name());
    }

    @Override
    public void onInterstitialShown(MoPubInterstitial interstitial) {
    	Log.d (CLASS_TAG, "Mopub onInterstitialShown");    	
    }

    @Override
    public void onInterstitialClicked(MoPubInterstitial interstitial) {
    	Log.d (CLASS_TAG, "Mopub onInterstitialClicked");    	
    }

    @Override
    public void onInterstitialDismissed(MoPubInterstitial interstitial) {
    	Log.d (CLASS_TAG, "Mopub onInterstitialDismissed");  
    	
    	// Cache a new ad
    	mInterstitial.load();
    }
}
