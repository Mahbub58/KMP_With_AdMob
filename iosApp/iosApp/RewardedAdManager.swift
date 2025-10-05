import SwiftUI
import GoogleMobileAds

class RewardedAdManager: NSObject, ObservableObject, FullScreenContentDelegate {
    @Published var isAdReady = false
    @Published var isLoading = false
    private var rewardedAd: RewardedAd?
    private var didEarnReward = false
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313" // Test rewarded ad unit ID

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

        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                    self?.isAdReady = false
                    return
                }

                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.isAdReady = true
                print("Rewarded ad loaded successfully")
            }
        }
    }

    func showAd() {
        guard let rewardedAd = rewardedAd,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            print("Rewarded ad not ready or no root view controller")
            return
        }

        didEarnReward = false
        rewardedAd.present(from: rootViewController) {
            let reward = rewardedAd.adReward
            self.didEarnReward = true
            let points = reward.amount.intValue
            print("Reward received with amount \(points)")
            NotificationCenter.default.post(
                name: NSNotification.Name("RewardedAdEarned"),
                object: nil,
                userInfo: ["amount": points]
            )
        }
    }

    // MARK: - FullScreenContentDelegate

    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        print("Rewarded ad recorded an impression")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        print("Rewarded ad was clicked")
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Rewarded ad failed to present full screen content with error: \(error.localizedDescription)")
        isAdReady = false
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Rewarded ad will present full screen content")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Rewarded ad did dismiss full screen content")
        // If a reward was not posted during presentation, signal not earned
        if !didEarnReward {
            NotificationCenter.default.post(
                name: NSNotification.Name("RewardedAdNotEarned"),
                object: nil,
                userInfo: ["amount": 0]
            )
        }
        isAdReady = false
        loadAd()
    }
}