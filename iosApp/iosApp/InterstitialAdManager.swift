import SwiftUI
import GoogleMobileAds

class InterstitialAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    @Published var isAdReady = false
    @Published var isLoading = false

    private var interstitialAd: InterstitialAd?
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910" // Test ad unit ID

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        guard !isLoading else {
            return
        }

        isLoading = true
        let request = Request()

        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    self?.isAdReady = false
                    return
                }

                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                self?.isAdReady = true
                print("Interstitial ad loaded successfully")
            }
        }
    }

    func showAd() {
        guard let interstitialAd = interstitialAd,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            print("Interstitial ad not ready or no root view controller")
            return
        }

        interstitialAd.present(from: rootViewController)
    }

    // MARK: - FullScreenContentDelegate
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad recorded an impression")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad was clicked")
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Interstitial ad failed to present full screen content with error: \(error.localizedDescription)")
        isAdReady = false
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad will present full screen content")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Interstitial ad did dismiss full screen content")
        isAdReady = false
        // Load a new ad for next time
        loadAd()
    }
}