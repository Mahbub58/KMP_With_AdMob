package com.mahbub.admobwithkmp.AdMob

import android.app.Activity
import android.content.Context
import android.os.Build
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.ui.viewinterop.AndroidView
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import kotlin.apply

@Composable
actual fun AdMobInlineAdaptiveBanner(modifier: Modifier) {
    AndroidView(
        modifier = modifier.fillMaxWidth(),
        factory = { context ->
            AdView(context).apply {
                val adWidthDp = getInlineAdaptiveAdWidthDp(context)
                val adaptiveSize = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(context, adWidthDp)
                setAdSize(adaptiveSize)
                adUnitId = "ca-app-pub-3940256099942544/9214589741"
                loadAd(AdRequest.Builder().build())
            }
        }
    )
}

private fun getInlineAdaptiveAdWidthDp(context: Context): Int {
    val displayMetrics = context.resources.displayMetrics
    val adWidthPixels = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && context is Activity) {
        // Use window metrics on Android 11+ when Activity is available
        context.windowManager.currentWindowMetrics.bounds.width()
    } else {
        // Fallback to display metrics width
        displayMetrics.widthPixels
    }
    val density = displayMetrics.density
    return (adWidthPixels / density).toInt()
}