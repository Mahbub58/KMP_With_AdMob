package com.mahbub.admobwithkmp

import androidx.compose.ui.window.ComposeUIViewController
import platform.UIKit.UIViewController

lateinit var IOSBanner: () -> UIViewController
lateinit var IOSInlineAdaptiveBanner: () -> UIViewController
fun generateIOSBanner(): UIViewController {
    return IOSBanner()
}
fun generateIOSInlineAdaptiveBanner(): UIViewController {
    return IOSInlineAdaptiveBanner()
}

fun MainViewController() = ComposeUIViewController { App() }