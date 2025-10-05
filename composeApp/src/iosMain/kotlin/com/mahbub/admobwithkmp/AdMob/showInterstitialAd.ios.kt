package com.mahbub.admobwithkmp.AdMob

import platform.Foundation.NSNotificationCenter

actual fun showInterstitialAd() {
    NSNotificationCenter.defaultCenter.postNotificationName(
        "ShowInterstitialAd",
        null
    )
}