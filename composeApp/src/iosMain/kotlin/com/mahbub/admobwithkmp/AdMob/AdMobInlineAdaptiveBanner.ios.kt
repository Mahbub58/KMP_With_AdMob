package com.mahbub.admobwithkmp.AdMob

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.UIKitInteropProperties
import androidx.compose.ui.viewinterop.UIKitView
import com.mahbub.admobwithkmp.generateIOSInlineAdaptiveBanner

@Composable
actual fun AdMobInlineAdaptiveBanner(modifier: Modifier) {
    UIKitView(
        factory = {
            generateIOSInlineAdaptiveBanner().view
        },
        // Let iOS adaptive banner determine its own height; only fill width.
        modifier = modifier.fillMaxWidth().heightIn(320.dp),
        update = { },
        properties = UIKitInteropProperties(
            isInteractive = true,
            isNativeAccessibilityEnabled = true
        )
    )
}