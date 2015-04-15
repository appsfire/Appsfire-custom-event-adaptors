package com.appsfire.mopubmediationdemo;

import java.util.Comparator;
import java.util.List;

import com.mopub.nativeads.MoPubAdAdapter;
import com.mopub.nativeads.MoPubNativeAdPositioning;
import com.mopub.nativeads.MoPubNativeAdRenderer;
import com.mopub.nativeads.RequestParameters;
import com.mopub.nativeads.ViewBinder;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

public class AdListView extends ListView {
	final static String MY_NATIVE_AD_UNIT_ID = "b608eb7807194187b3586cb25c84a0ee";
	// Activity context
	Context m_context;
	
	// Package manager for context
	PackageManager m_packageManager;
	
	// List of installed apps
	List<ResolveInfo> m_appsList;
	
	AdListAdapter m_adListAdapter;
	
	MoPubAdAdapter m_mopubNativeAdAdapter;
	
	class ResolveInfoComparatorByAppName implements Comparator<ResolveInfo> {
	    @Override
	    public int compare(ResolveInfo o1, ResolveInfo o2) {
	    	String label1 = o1.loadLabel(m_packageManager).toString();
	    	String label2 = o2.loadLabel(m_packageManager).toString();
	    	
	        return label1.compareTo(label2);
	    }
	}
	
	public AdListView(Context context) {
		super(context);
		m_context = context;
		initialize ();
	}
	
	public AdListView(Context context, AttributeSet attrs) {
		super(context, attrs);
		m_context = context;
		initialize ();
	}
	
	private void initialize() {
		ViewBinder viewBinder = new ViewBinder.Builder(R.layout.native_ad_layout)
														.mainImageId(R.id.native_ad_main_image)
														.iconImageId(R.id.native_ad_icon_image)
														.titleId(R.id.native_ad_title)
														.textId(R.id.native_ad_text)
														.build();

		MoPubNativeAdPositioning.MoPubServerPositioning adPositioning = 
				MoPubNativeAdPositioning.serverPositioning();
		MoPubNativeAdRenderer adRenderer = new MoPubNativeAdRenderer(viewBinder);		


		m_adListAdapter = new AdListAdapter();

		m_mopubNativeAdAdapter = new MoPubAdAdapter(m_context, m_adListAdapter, adPositioning);
		m_mopubNativeAdAdapter.registerAdRenderer(adRenderer);

		setAdapter(m_mopubNativeAdAdapter);
		
		m_mopubNativeAdAdapter.loadAds(MY_NATIVE_AD_UNIT_ID, null);
	}

	// List adapter for selecting an app to be injected
	
	public class AdListAdapter extends BaseAdapter {						
		public AdListAdapter() {
			super();			
		}

		@Override
		public int getCount() {
			return 3;
		}

		@Override
		public Object getItem(int position) {
			return null;
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@SuppressLint("ViewHolder")
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			LinearLayout entryView = null;
			
			if (convertView == null) {
				LayoutInflater inflater = (LayoutInflater) m_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				entryView = (LinearLayout) inflater.inflate(R.layout.native_row, parent, false);
			}
			else {
				entryView = (LinearLayout) convertView;
			}
			TextView textView = (TextView) entryView.findViewById(R.id.lvItem);				
			
			textView.setText ("Entry " + (position + 1));
			
			return entryView;
		}
	}
}