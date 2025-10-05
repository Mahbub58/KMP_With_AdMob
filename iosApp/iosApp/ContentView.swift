import UIKit
import SwiftUI
import ComposeApp

struct ComposeView: UIViewControllerRepresentable {
    init() {
        MainViewControllerKt.IOSBanner = {
            return BannerAdBridge.shared.createBannerAdViewController()
        }
        MainViewControllerKt.IOSInlineAdaptiveBanner = {
            return InlineAdaptiveBannerBridge.shared.createInlineAdaptiveBannerViewController()
        }
    }
    func makeUIViewController(context: Context) -> UIViewController {
        MainViewControllerKt.MainViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

struct ContentView: View {
    @EnvironmentObject var consentManager: ConsentManager
    @StateObject private var interstitialAdManager = InterstitialAdManager()
    @StateObject private var rewardedAdManager = RewardedAdManager()
    @State private var shouldShowRewardedOnReady = false
    var body: some View {
        ComposeView()
        .ignoresSafeArea(.keyboard)
        .onAppear {
            // Load interstitial ad when consent is available
            if consentManager.canRequestAds {
                interstitialAdManager.loadAd()
                // rewardedAdManager.loadAd()
            }

            // Add notification observer for interstitial ad trigger
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ShowInterstitialAd"),
                object: nil,
                queue: .main
            ) { _ in
                if interstitialAdManager.isAdReady {
                    interstitialAdManager.showAd()
                } else {
                    // Load ad if not ready and show when loaded
                    interstitialAdManager.loadAd()
                }
            }
            // Add notification observer for rewarded ad trigger
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("ShowRewardedAd"),
                object: nil,
                queue: .main
            ) { _ in
                if rewardedAdManager.isAdReady {
                    rewardedAdManager.showAd()
                } else {
                    // Load now and show automatically once ready
                    shouldShowRewardedOnReady = true
                    rewardedAdManager.loadAd()
                }
            }
        }
        .onChange(of: consentManager.canRequestAds) { canRequest in
            if canRequest {
                interstitialAdManager.loadAd()
                rewardedAdManager.loadAd()
            }
        }
        .onChange(of: rewardedAdManager.isAdReady) { ready in
            if ready && shouldShowRewardedOnReady {
                rewardedAdManager.showAd()
                shouldShowRewardedOnReady = false
            }

        }
    }
}




