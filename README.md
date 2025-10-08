# AdMobWithKMP

Kotlin Multiplatform Mobile project integrating Google AdMob on Android (Jetpack Compose) and iOS (SwiftUI). iOS also includes Google User Messaging Platform (UMP) for consent. Use this template to add banner, inline adaptive banner, interstitial, and rewarded ads while keeping platform-specific code separated and shared UI/state in `commonMain`.

## Table of Contents
- Overview
- Features
- Dependencies
- Project Structure
  - Common (KMP)
  - Android
  - iOS
  - Full Tree
- Technical Process
- Flowchart
- Shared Architecture (commonMain)
- Android Implementation
- iOS Implementation
- Setup (Android/iOS)
- Integration Checklist
- Build & Commands
- Notes & Pitfalls
- Contributing
- License
- Acknowledgements

## Overview
- Multiplatform app with shared UI/state in `commonMain`.
- Android uses `play-services-ads`; iOS uses `Google-Mobile-Ads-SDK` + `GoogleUserMessagingPlatform`.
- Consent requested on iOS before loading personalized ads; test ad units used during development.

## Features
- Banner and Inline Adaptive Banner (SwiftUI)
- Interstitial and Rewarded (Swift managers)
- Android AdMob integration using Play Services Ads
- iOS consent with UMP prior to loading ads
- Shared KMP UI/state in `commonMain`

## Dependencies
- Kotlin/Compose
  - Compose Multiplatform: `1.9.0`
  - Kotlin: `2.2.20`
  - Android Gradle Plugin: `8.11.2`
- Android
  - `com.google.android.gms:play-services-ads:24.6.0`
  - AndroidX Activity Compose, Lifecycle Compose, Material3 (via Compose)
  - compileSdk: `36`, targetSdk: `36`, minSdk: `24`
- iOS (CocoaPods)
  - `Google-Mobile-Ads-SDK`
  - `GoogleUserMessagingPlatform`
  - Deployment target: iOS 13+

## Project Structure

### Common (KMP)
```
composeApp/src/
├── commonMain/
│   ├── kotlin/…                # Shared Compose UI/state, view models, contracts
│   └── composeResources/
│       └── drawable/…          # Shared resources (Compose Multiplatform)
└── iosMain/
    └── kotlin/…                # iOS interop stubs (if needed)
```

### Android
```
composeApp/
├── build.gradle.kts            # KMP + Android application module
└── src/androidMain/
    ├── AndroidManifest.xml     # Add AdMob App ID meta-data
    ├── kotlin/…                # Android-specific ad code (wrappers, setup)
    └── res/
        ├── drawable/…
        ├── mipmap-*/…
        └── values/…           # Android resources
```

### iOS
```
iosApp/
├── Podfile                         # Google-Mobile-Ads-SDK + UMP
├── iosApp/
│   ├── iOSApp.swift                # App entry
│   ├── Info.plist                  # GADApplicationIdentifier + SKAdNetwork IDs
│   ├── ContentView.swift           # Example SwiftUI view
│   ├── BannerAdView.swift          # Banner view
│   ├── InlineAdaptiveBannerView.swift
│   ├── InterstitialAdManager.swift # Interstitial manager
│   ├── RewardedAdManager.swift     # Rewarded manager
│   ├── ConsentManager.swift        # UMP consent flow
│   ├── GoogleMobileAdsConsentManager.h
│   └── GoogleMobileAdsConsentManager.m
└── iosApp.xcworkspace
```

### Full Tree
```
AdMobWithKMP/
├── build.gradle.kts
├── settings.gradle.kts
├── gradle/
│   ├── libs.versions.toml          # Centralized versions (Kotlin, Compose, Ads)
│   └── wrapper/
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── composeApp/
│   ├── build.gradle.kts
│   └── src/
│       ├── commonMain/
│       │   ├── kotlin/…
│       │   └── composeResources/
│       │       └── drawable/…
│       ├── androidMain/
│       │   ├── AndroidManifest.xml
│       │   ├── kotlin/…
│       │   └── res/
│       │       ├── drawable/…
│       │       ├── mipmap-*/…
│       │       └── values/…
│       ├── commonTest/
│       │   └── kotlin/…
│       └── iosMain/
│           └── kotlin/…
├── iosApp/
│   ├── Configuration/
│   │   └── Config.xcconfig         # Bundle ID/version templating
│   ├── Podfile
│   ├── iosApp/
│   │   ├── Assets.xcassets/…
│   │   ├── iOSApp.swift
│   │   ├── Info.plist
│   │   ├── ContentView.swift
│   │   ├── BannerAdView.swift
│   │   ├── InlineAdaptiveBannerView.swift
│   │   ├── InterstitialAdManager.swift
│   │   ├── RewardedAdManager.swift
│   │   ├── ConsentManager.swift
│   │   ├── GoogleMobileAdsConsentManager.h
│   │   └── GoogleMobileAdsConsentManager.m
│   └── iosApp.xcworkspace
└── README.md
```

## Technical Process
1. App launches.
2. iOS requests user consent via UMP (`ConsentManager`).
3. Initialize Ads SDK early:
   - Android: `MobileAds.initialize(context)`
   - iOS: `GADMobileAds.sharedInstance().start(completionHandler: nil)`
4. Load ad units (banner/interstitial/rewarded) using test IDs during development.
5. Display the ad when ready; handle callbacks for errors/reward events.

## Flowchart
```
------------------+
|    App Launch    |
---------+--------+
          |
          v
------------------+
| iOS: Request UMP |
| consent (if req) |
---------+--------+
          |
          v
-------------------------+
| Initialize Ads SDK      |
| Android/iOS             |
---------+---------------+
          |
          v
-------------------------+
| Load Ad (Banner/Inter/  |
| Rewarded) with test IDs |
---------+---------------+
          |
          v
-------------------------+
| Show Ad / Update UI     |
---------+---------------+
          |
          v
-------------------------+
| Handle callbacks/errors |
-------------------------+
```

## Shared Architecture (commonMain)
- Goal: keep UI state and ad triggers in shared code; delegate actual load/show to platform implementations.
- Pattern: define shared interfaces in `commonMain` and implement them on Android/iOS.

Conceptual interfaces:
```kotlin
// commonMain
enum class AdType { Banner, Interstitial, Rewarded }

interface AdEvents {
    fun onLoaded(type: AdType)
    fun onFailed(type: AdType, error: String)
    fun onShown(type: AdType)
    fun onDismissed(type: AdType)
    fun onUserEarnedReward(amount: Double, typeLabel: String)
}

interface AdController {
    fun initialize()
    fun loadBanner(adUnitId: String)
    fun loadInterstitial(adUnitId: String)
    fun loadRewarded(adUnitId: String)
    fun showInterstitial(): Boolean
    fun showRewarded(): Boolean
}

class AdViewModel(private val controller: AdController, private val events: AdEvents) {
    fun start() = controller.initialize()
    fun requestBanner(id: String) = controller.loadBanner(id)
    fun requestInterstitial(id: String) = controller.loadInterstitial(id)
    fun requestRewarded(id: String) = controller.loadRewarded(id)
}
```

## Android Implementation
- Dependencies: `com.google.android.gms:play-services-ads:24.6.0` and Compose.
- Manifest: add `com.google.android.gms.ads.APPLICATION_ID` meta-data.
- Initialization: call `MobileAds.initialize(context)` once early.

Compose banner example:
```kotlin
@Composable
fun BannerAd(modifier: Modifier = Modifier, adUnitId: String) {
    AndroidView(
        modifier = modifier,
        factory = { ctx ->
            AdView(ctx).apply {
                adSize = AdSize.BANNER
                adUnitId = adUnitId // Use test ID in dev
                loadAd(AdRequest.Builder().build())
            }
        }
    )
}
```

Interstitial example:
```kotlin
fun loadInterstitial(context: Context, adUnitId: String, onReady: (InterstitialAd) -> Unit) {
    InterstitialAd.load(
        context,
        adUnitId,
        AdRequest.Builder().build(),
        object : InterstitialAdLoadCallback() {
            override fun onAdLoaded(ad: InterstitialAd) = onReady(ad)
            override fun onAdFailedToLoad(error: LoadAdError) { /* handle */ }
        }
    )
}
```

Rewarded example:
```kotlin
fun loadRewarded(context: Context, adUnitId: String, onReady: (RewardedAd) -> Unit) {
    RewardedAd.load(
        context,
        adUnitId,
        AdRequest.Builder().build(),
        object : RewardedAdLoadCallback() {
            override fun onAdLoaded(ad: RewardedAd) = onReady(ad)
            override fun onAdFailedToLoad(error: LoadAdError) { /* handle */ }
        }
    )
}
```

Test unit IDs (development):
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

## iOS Implementation
- Pods: `Google-Mobile-Ads-SDK`, `GoogleUserMessagingPlatform`.
- Info.plist: set `GADApplicationIdentifier` (sample App ID included; replace for production).
- Initialization: `GADMobileAds.sharedInstance().start(completionHandler: nil)`.
- Consent: request via `ConsentManager` (UMP) before loading personalized ads.

Banner (SwiftUI) example:
```swift
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitId: String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: kGADAdSizeBanner)
        banner.adUnitID = adUnitId
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner
    }
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
```

Interstitial:
```swift
final class InterstitialAdManager: NSObject {
    private var ad: GADInterstitialAd?

    func load(adUnitId: String) {
        GADInterstitialAd.load(withAdUnitID: adUnitId, request: GADRequest()) { ad, error in
            self.ad = ad
        }
    }

    func show(from vc: UIViewController) {
        ad?.present(fromRootViewController: vc)
    }
}
```

Rewarded:
```swift
final class RewardedAdManager: NSObject {
    private var ad: GADRewardedAd?

    func load(adUnitId: String) {
        GADRewardedAd.load(withAdUnitID: adUnitId, request: GADRequest()) { ad, error in
            self.ad = ad
        }
    }

    func show(from vc: UIViewController, onReward: @escaping (GADAdReward) -> Void) {
        ad?.present(fromRootViewController: vc) {
            if let reward = self.ad?.adReward { onReward(reward) }
        }
    }
}
```

Consent (UMP):
```swift
import GoogleUserMessagingPlatform

final class ConsentManager {
    func requestConsentIfNeeded(completion: @escaping (UMPConsentStatus) -> Void) {
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: UMPRequestParameters()) { error in
            let status = UMPConsentInformation.sharedInstance.consentStatus
            completion(status)
        }
    }
}
```

## Setup

### Android
1. Open the project in Android Studio (API 36 SDK installed).
2. Set AdMob App ID in `composeApp/src/androidMain/AndroidManifest.xml`:
   ```xml
   <meta-data
     android:name="com.google.android.gms.ads.APPLICATION_ID"
     android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
   ```
3. Initialize Ads:
   ```kotlin
   import com.google.android.gms.ads.MobileAds
   MobileAds.initialize(context)
   ```
4. Use Google test ad units:
   - Banner: `ca-app-pub-3940256099942544/6300978111`
   - Interstitial: `ca-app-pub-3940256099942544/1033173712`
   - Rewarded: `ca-app-pub-3940256099942544/5224354917`
5. Run:
   ```bash
   ./gradlew :composeApp:installDebug
   ```

### iOS
1. Install pods:
   ```bash
   cd iosApp && pod install
   ```
2. Open `iosApp.xcworkspace`.
3. Set AdMob App ID in `iosApp/iosApp/Info.plist` under `GADApplicationIdentifier`.
   - Currently set to Google’s sample App ID: `ca-app-pub-3940256099942544~1458002511` (replace for production).
4. Initialize Ads at app start:
   ```swift
   import GoogleMobileAds
   GADMobileAds.sharedInstance().start(completionHandler: nil)
   ```
5. Request consent (iOS):
   ```swift
   let consentManager = ConsentManager()
   consentManager.requestConsentIfNeeded { status in
       // Load ads after consent
   }
   ```
6. Run the `iosApp` scheme on a simulator/device.

## Integration Checklist
- Common
  - Define shared contracts in `commonMain` (interfaces, events).
  - Keep UI state and triggers in shared ViewModels.
- Android
  - Add App ID meta-data in manifest.
  - Initialize Ads in `Application` or first `Activity`.
  - Use Compose `AndroidView` for banners; load interstitial/rewarded as needed.
- iOS
  - Install pods and set `GADApplicationIdentifier` in Info.plist.
  - Initialize Ads at app start; request UMP consent.
  - Use SwiftUI wrappers/managers to load/show ads.

## Build & Commands
- Android assemble: `./gradlew :composeApp:assembleDebug`
- Android install: `./gradlew :composeApp:installDebug`
- iOS Pods: `cd iosApp && pod install`

## Notes & Pitfalls
- Use test ad units until your app is approved.
- Obtain consent where required before loading personalized ads.
- Keep SKAdNetwork IDs current if partners require them.
- Initialize the Ads SDK once, early in lifecycle.

## Contributing
PRs welcome. For large changes, open an issue to discuss first.

## License
Add a license (MIT/Apache-2.0) before production use.

## Acknowledgements
- Google Mobile Ads SDK
- Google User Messaging Platform (UMP)
- JetBrains Kotlin Multiplatform & Compose Multiplatform