package com.mahbub.admobwithkmp.AdMob

import android.annotation.SuppressLint
import android.app.Activity
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback

@SuppressLint("StaticFieldLeak")
object AndroidActivityHolder {
    var current: Activity? = null
}

object AndroidInterstitialAdManager {
    private var interstitialAd: InterstitialAd? = null
    private const val AD_UNIT_ID = "ca-app-pub-3940256099942544/1033173712" // Test ad unit ID

    fun load(activity: Activity, showOnLoad: Boolean = false) {
        val request = AdRequest.Builder().build()
        InterstitialAd.load(
            activity,
            AD_UNIT_ID,
            request,
            object : InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) {
                    interstitialAd = ad
                    ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                        override fun onAdDismissedFullScreenContent() {
                            interstitialAd = null
                            // Preload next ad
                            load(activity, showOnLoad = false)
                        }
                    }
                    if (showOnLoad) {
                        ad.show(activity)
                    }
                }

                override fun onAdFailedToLoad(error: LoadAdError) {
                    interstitialAd = null
                }
            }
        )
    }

    fun show(activity: Activity) {
        val ad = interstitialAd
        if (ad != null) {
            ad.show(activity)
        } else {
            load(activity, showOnLoad = true)
        }
    }
}
