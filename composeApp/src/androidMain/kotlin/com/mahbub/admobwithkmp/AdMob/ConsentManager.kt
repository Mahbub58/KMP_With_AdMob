package com.mahbub.admobwithkmp.AdMob

import android.app.Activity
import android.util.Log
import com.google.android.gms.ads.MobileAds
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform

private lateinit var consentInformation: ConsentInformation

fun ConsentManager(
    activity: Activity,
    onResult: (Boolean) -> Unit
) {
    consentInformation = UserMessagingPlatform.getConsentInformation(activity)

    val debugSettings = ConsentDebugSettings.Builder(activity)
        .setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
        .addTestDeviceHashedId("5DFDEB37FBA78D0F68DA91C82F1B8B48")
        .build()

    val params = ConsentRequestParameters.Builder()
        .setConsentDebugSettings(debugSettings)
        .build()

    // Requesting consent info update should be done on every app launch.
    consentInformation.requestConsentInfoUpdate(
        activity,
        params,
        {
            // On success
            UserMessagingPlatform.loadAndShowConsentFormIfRequired(activity) { loadError ->
                if (loadError != null) {
                    onResult(false)
                    return@loadAndShowConsentFormIfRequired
                }

                if (consentInformation.canRequestAds()) {
                    MobileAds.initialize(activity)
                    onResult(true)
                } else {
                    onResult(false)
                }
            }
        },
        { requestError ->
            // Handle failure gracefully
            Log.e("ConsentManager", "Consent update failed: ${requestError.message}")
            onResult(false)
        }
    )
}
