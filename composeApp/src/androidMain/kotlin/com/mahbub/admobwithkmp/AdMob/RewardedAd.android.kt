package com.mahbub.admobwithkmp.AdMob

import com.google.android.gms.ads.AdError
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.FullScreenContentCallback
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.rewarded.RewardItem
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import kotlinx.coroutines.suspendCancellableCoroutine

suspend fun RewardedAd(): Int = suspendCancellableCoroutine { cont ->
    val activity = AndroidActivityHolder.current
    if (activity == null) {
        cont.resume(0) {}
        return@suspendCancellableCoroutine
    }

    val adUnitId = "ca-app-pub-3940256099942544/5224354917" // Test rewarded ad unit ID
    RewardedAd.load(
        activity,
        adUnitId,
        AdRequest.Builder().build(),
        object : RewardedAdLoadCallback() {
            override fun onAdLoaded(ad: RewardedAd) {
                ad.fullScreenContentCallback = object : FullScreenContentCallback() {
                    override fun onAdFailedToShowFullScreenContent(adError: AdError) {
                        if (!cont.isCompleted) cont.resume(0) {}
                    }

                    override fun onAdDismissedFullScreenContent() {
                        if (!cont.isCompleted) cont.resume(0) {}
                    }
                }

                ad.show(activity) { rewardItem: RewardItem ->
                    val points = rewardItem.amount
                    if (!cont.isCompleted) cont.resume(points) {}
                }
            }

            override fun onAdFailedToLoad(error: LoadAdError) {
                if (!cont.isCompleted) cont.resume(0) {}
            }
        }
    )
}