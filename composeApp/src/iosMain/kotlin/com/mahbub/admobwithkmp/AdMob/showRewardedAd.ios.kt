package com.mahbub.admobwithkmp.AdMob

import kotlinx.coroutines.suspendCancellableCoroutine
import platform.Foundation.NSNotification
import platform.Foundation.NSNotificationCenter
import platform.Foundation.NSNumber

actual suspend fun showRewardedAd(): Int = suspendCancellableCoroutine { cont ->
    val center = NSNotificationCenter.defaultCenter

    var earnedObserver: Any? = null
    var notEarnedObserver: Any? = null

    fun complete(points: Int) {
        if (earnedObserver != null) {
            center.removeObserver(earnedObserver!!)
            earnedObserver = null
        }
        if (notEarnedObserver != null) {
            center.removeObserver(notEarnedObserver!!)
            notEarnedObserver = null
        }
        if (!cont.isCompleted) cont.resume(points) {}
    }

    earnedObserver =
        center.addObserverForName("RewardedAdEarned", null, null) { notification: NSNotification? ->
            val amount = ((notification?.userInfo?.get("amount")) as? NSNumber)?.intValue ?: 0
            complete(amount)
        }

    notEarnedObserver =
        center.addObserverForName("RewardedAdNotEarned", null, null) { _: NSNotification? ->
            complete(0)
        }

    // Ask iOS to show the rewarded ad
    center.postNotificationName("ShowRewardedAd", null)

    cont.invokeOnCancellation {
        if (earnedObserver != null) {
            center.removeObserver(earnedObserver!!)
            earnedObserver = null
        }
        if (notEarnedObserver != null) {
            center.removeObserver(notEarnedObserver!!)
            notEarnedObserver = null
        }
    }
}