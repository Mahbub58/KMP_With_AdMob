# AdMobWithKMP

Kotlin Multiplatform Mobile project integrating Google AdMob on Android (Jetpack Compose) and iOS (SwiftUI). The iOS side also includes Google User Messaging Platform (UMP) for consent. Use it as a template to add banner, inline adaptive banner, interstitial, and rewarded ads while keeping platform-specific code in their own modules.

## Android Project Structure
composeApp/
├── build.gradle.kts
└── src/
    ├── commonMain/                 # Shared Compose UI/state
    │   └── kotlin/…
    ├── androidMain/                # Android-specific code
    │   ├── AndroidManifest.xml     # Add AdMob App ID meta-data
    │   └── kotlin/…                # Ad loaders, UI wrappers
    └── iosMain/                    # iOS interop stubs (for KMP)


## iOS Project Structure

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

## Dependencies (Highlighted)
- Kotlin/Compose:
  - Compose Multiplatform: `1.9.0`
  - Kotlin: `2.2.20`
  - Android Gradle Plugin: `8.11.2`
- Android:
  - `com.google.android.gms:play-services-ads:24.6.0`
  - AndroidX Activity Compose, Lifecycle Compose, Material3 (via Compose)
- iOS (CocoaPods):
  - `Google-Mobile-Ads-SDK`
  - `GoogleUserMessagingPlatform`

## Features
- Banner and Inline Adaptive Banner (SwiftUI)
- Interstitial and Rewarded (Swift managers)
- Android AdMob integration using Play Services Ads
- iOS consent with UMP prior to loading ads
- Shared KMP UI/state in `commonMain`

## Full Project Structure (Common, Android, iOS)
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
│   ├── build.gradle.kts            # KMP + Android application module
│   └── src/
│       ├── commonMain/
│       │   ├── kotlin/
│       │   │   └── com/…           # Shared Compose UI/state, view models, contracts
│       │   └── composeResources/
│       │       └── drawable/…      # Shared resources (Compose Multiplatform)
│       ├── androidMain/
│       │   ├── AndroidManifest.xml # App ID meta-data for AdMob (Android)
│       │   ├── kotlin/
│       │   │   └── com/…           # Android-specific code (ad wrappers, setup)
│       │   └── res/
│       │       ├── drawable/…
│       │       ├── mipmap-*/…
│       │       └── values/…        # Android resources
│       ├── commonTest/
│       │   └── kotlin/
│       │       └── com/…           # Shared tests
│       └── iosMain/
│           └── kotlin/
│               └── com/…           # iOS interop stubs for KMP (if needed)
├── iosApp/
│   ├── Configuration/
│   │   └── Config.xcconfig         # Bundle ID/version templating
│   ├── Podfile                     # Google-Mobile-Ads-SDK + UMP
│   ├── iosApp/
│   │   ├── Assets.xcassets/…
│   │   ├── iOSApp.swift            # App entry
│   │   ├── Info.plist              # GADApplicationIdentifier + SKAdNetwork IDs
│   │   ├── ContentView.swift       # Example SwiftUI view
│   │   ├── BannerAdView.swift      # Banner view
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
3. Initialize the Ads SDK early:
   - Android: `MobileAds.initialize(context)`
   - iOS: `GADMobileAds.sharedInstance().start(completionHandler: nil)`
4. Load ad units (banner/interstitial/rewarded) using test IDs during development.
5. Display the ad when ready; handle callbacks for errors/reward events.

### Flowchart
```
+------------------+
|    App Launch    |
+---------+--------+
          |
          v
+------------------+
| iOS: Request UMP |
| consent (if req) |
+---------+--------+
          |
          v
+-------------------------+
| Initialize Ads SDK      |
| Android/iOS             |
+---------+---------------+
          |
          v
+-------------------------+
| Load Ad (Banner/Inter/  |
| Rewarded) with test IDs |
+---------+---------------+
          |
          v
+-------------------------+
| Show Ad / Update UI     |
+---------+---------------+
          |
          v
+-------------------------+
| Handle callbacks/errors |
+-------------------------+
```

## Ads from `commonMain` (Architecture)
- Purpose: keep UI state and ad triggers in shared code, while delegating actual ad loading/showing to platform implementations.
- Pattern: define shared interfaces in `commonMain`, and implement them on Android/iOS.

Example shared contracts in `commonMain` (conceptual):
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

- Android and iOS provide platform `AdController` implementations wired to Google SDKs.
- Shared UI can call `AdViewModel` methods and react to `AdEvents` to update the UI.

This project keeps platform-specific loading/showing logic in Android (`androidMain`) and iOS (`iosApp/*.swift`), while shared UI/state live in `commonMain`.

## Android Implementation Details
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

Tip: use test IDs during development:
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

## iOS Implementation Details
- Pods: `Google-Mobile-Ads-SDK`, `GoogleUserMessagingPlatform`.
- Info.plist: set `GADApplicationIdentifier` (sample currently used in repo).
- Initialization: `GADMobileAds.sharedInstance().start(completionHandler: nil)`.
- Consent: request via `ConsentManager` (UMP) before loading personalized ads.

Banner (SwiftUI) example (similar to `BannerAdView.swift`):
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

Interstitial (similar to `InterstitialAdManager.swift`):
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

Rewarded (similar to `RewardedAdManager.swift`):
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

Consent (UMP) example (similar to `ConsentManager.swift`):
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
4. Initialize Ads in app start:
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