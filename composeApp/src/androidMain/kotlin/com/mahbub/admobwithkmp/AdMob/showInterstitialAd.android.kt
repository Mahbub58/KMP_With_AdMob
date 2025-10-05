package com.mahbub.admobwithkmp.AdMob


actual fun showInterstitialAd() {
    val activity = AndroidActivityHolder.current ?: return
    AndroidInterstitialAdManager.show(activity)
}