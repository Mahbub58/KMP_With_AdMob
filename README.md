# AdMobWithKMP

Kotlin Multiplatform Mobile sample integrating Google AdMob on both Android and iOS. The Android side uses Jetpack Compose with Google Play Services Ads, while the iOS side uses SwiftUI with the Google-Mobile-Ads-SDK (CocoaPods) and the Google User Messaging Platform (UMP) for privacy consent.

This project is a practical starting point to add banner, inline adaptive banner, interstitial, and rewarded ads to a KMP app, keeping platform-specific ad implementations cleanly separated.

## Tech Stack
- Kotlin Multiplatform with Compose Multiplatform `1.9.0`
- Kotlin `2.2.20`, Android Gradle Plugin `8.11.2`
- Android SDK: compile `36`, target `36`, min `24`
- iOS target: iOS 13+
- Android Ads: `com.google.android.gms:play-services-ads:24.6.0`
- iOS Ads: `Google-Mobile-Ads-SDK` and `GoogleUserMessagingPlatform` via CocoaPods

## Features
- Banner ads and inline adaptive banners (iOS SwiftUI views)
- Interstitial and rewarded ads (iOS managers)
- Android integration via Play Services Ads in `androidMain`
- Consent management with Google UMP on iOS
- KMP structure with shared UI state in `commonMain`

## Project Structure
```
AdMobWithKMP/
├── composeApp/                 # KMP module (Android app + shared Compose UI)
│   ├── build.gradle.kts        # Android + KMP config, Compose deps
│   └── src/
│       ├── androidMain/        # Android-specific code & manifest
│       ├── commonMain/         # Shared Kotlin/Compose code
│       └── iosMain/            # iOS interop stubs (if any)
├── iosApp/                     # iOS app (SwiftUI)
│   ├── Podfile                 # CocoaPods with GMA + UMP
│   ├── iosApp/Info.plist       # Includes `GADApplicationIdentifier` + SKAdNetwork IDs
│   ├── iosApp/iOSApp.swift     # App entry point
│   └── iosApp/*.swift          # Banner/Interstitial/Rewarded/Consent managers
└── gradle/libs.versions.toml   # Centralized versions (Kotlin, Compose, Ads)
```

Key iOS files:
- `iosApp/iosApp/BannerAdView.swift`
- `iosApp/iosApp/InlineAdaptiveBannerView.swift`
- `iosApp/iosApp/InterstitialAdManager.swift`
- `iosApp/iosApp/RewardedAdManager.swift`
- `iosApp/iosApp/ConsentManager.swift`
- `iosApp/iosApp/GoogleMobileAdsConsentManager.{h,m}`

## Getting Started

### Prerequisites
- Android Studio (latest) with Kotlin plugin
- Xcode 15+ and CocoaPods (`sudo gem install cocoapods`)
- Java 11 (project sets `JVM_11`)

### Clone
```
git clone https://github.com/<your-username>/AdMobWithKMP.git
cd AdMobWithKMP
```

### Android Setup
1. Ensure you have the Android SDKs for API 36 installed.
2. Open the project in Android Studio.
3. Add your AdMob App ID to the Android manifest (`composeApp/src/androidMain/AndroidManifest.xml`):
   ```xml
   <manifest>
     <application>
       <meta-data
         android:name="com.google.android.gms.ads.APPLICATION_ID"
         android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
     </application>
   </manifest>
   ```
4. Initialize the Ads SDK early (e.g., in your `Activity` or `Application`):
   ```kotlin
   import com.google.android.gms.ads.MobileAds

   MobileAds.initialize(context)
   ```
5. Use Google test ad units during development. Example test IDs:
   - Banner: `ca-app-pub-3940256099942544/6300978111`
   - Interstitial: `ca-app-pub-3940256099942544/1033173712`
   - Rewarded: `ca-app-pub-3940256099942544/5224354917`

Run on Android:
```
./gradlew :composeApp:installDebug
```
Or click Run in Android Studio using the `composeApp` configuration.

### iOS Setup
1. Install pods:
   ```bash
   cd iosApp
   pod install
   ```
2. Open `iosApp/iosApp.xcworkspace` in Xcode.
3. Set your AdMob App ID in `iosApp/iosApp/Info.plist` under `GADApplicationIdentifier`.
   - The project currently uses the Google sample App ID: `ca-app-pub-3940256099942544~1458002511`.
4. (Optional) Review SKAdNetwork IDs in `Info.plist` to ensure they meet your partner requirements.
5. UMP (consent) is integrated via `ConsentManager.swift` and `GoogleUserMessagingPlatform`. Request consent at app start:
   ```swift
   let consentManager = ConsentManager()
   consentManager.requestConsentIfNeeded { status in
       // proceed to load ads after consent
   }
   ```
6. Initialize Google Mobile Ads early in app lifecycle:
   ```swift
   import GoogleMobileAds
   GADMobileAds.sharedInstance().start(completionHandler: nil)
   ```

Run on iOS:
- Select the `iosApp` scheme
- Choose a simulator or device
- Build & Run

### Configure Ad Units
- For development, always use Google-provided test ad units (listed above).
- For production, replace with your own AdMob ad unit IDs:
  - Android: banner/interstitial/rewarded IDs referenced wherever you load ads.
  - iOS: set IDs within the Swift managers or Info.plist depending on your implementation.

## How It Works
- Android: `composeApp/src/androidMain` adds `play-services-ads` and uses Jetpack Compose for UI. Load and show ads using the standard AdMob APIs.
- iOS: SwiftUI views and managers encapsulate ad loading and presentation. CocoaPods brings in the AdMob and UMP SDKs; consent is requested before loading ads to comply with privacy requirements.
- Shared KMP code in `commonMain` holds cross-platform UI logic/state; platform-specific ad code stays on each side.

## Common Pitfalls
- Consent must be obtained before loading personalized ads in regions where required.
- Use test ad units until your app is approved; live units can cause policy violations during testing.
- Keep SKAdNetwork IDs updated if your ad partners require them.
- Ensure you initialize the Ads SDK once, early in the lifecycle.

## Scripts & Commands
- Build Android debug: `./gradlew :composeApp:assembleDebug`
- Install Android debug on device/emulator: `./gradlew :composeApp:installDebug`
- iOS pods install: `cd iosApp && pod install`

## Contributing
Pull requests are welcome. For large changes, please open an issue first to discuss what you’d like to change.

## License
This repository is provided as-is for educational purposes. Add a license (e.g., MIT or Apache-2.0) before publishing to production.

## Acknowledgements
- Google Mobile Ads SDK
- Google User Messaging Platform (UMP)
- JetBrains Kotlin Multiplatform & Compose Multiplatform